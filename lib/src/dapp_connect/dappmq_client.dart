import 'dart:async';
import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:web3mq/src/dapp_connect/model/app_metadata.dart';
import 'package:web3mq/src/dapp_connect/model/participant.dart';
import 'package:web3mq/src/dapp_connect/model/request.dart';
import 'package:web3mq/src/dapp_connect/model/response.dart';
import 'package:web3mq/src/dapp_connect/model/rpc_response.dart';
import 'package:web3mq/src/dapp_connect/model/session_proposal_result.dart';
import 'package:web3mq/src/dapp_connect/model/uri.dart';
import 'package:web3mq/src/dapp_connect/serializer.dart';
import 'package:web3mq/src/dapp_connect/storage/record.dart';
import 'package:web3mq/src/dapp_connect/storage/storage.dart';
import 'package:web3mq/src/dapp_connect/utils/id_generator.dart';
import 'package:web3mq/src/logger/logger.dart';
import 'package:web3mq/src/utils/private_key_utils.dart';
import 'package:web3mq/web3mq.dart';

import '../error/error.dart';
import '../ws/websocket.dart';
import 'error/error.dart';
import 'model/message_payload.dart';
import 'model/namespace.dart';
import 'model/rpc_error.dart';
import 'model/rpc_request.dart';
import 'model/session.dart';
import 'model/user.dart';

///
abstract class DappConnectClientProtocol {
  ///
  Future<List<Session>> get sessions;

  ///
  Stream<Request> get requestStream;

  ///
  Stream<Response> get responseStream;

  ///
  Future<void> deleteSession(String topic);

  ///
  DappConnectURI createSessionProposalURI(
      Map<String, ProposalNamespace> requiredNamespaces);

  ///
  Future<void> approveSessionProposal(String proposalId,
      Map<String, SessionNamespace> sessionNamespace, Duration expires);

  ///
  Future<void> rejectSessionProposal(String proposalId);

  ///
  Future<void> sendSuccessResponse(
      Request request, Map<String, dynamic> result);

  ///
  Future<void> sendErrorResponse(Request request, int code, String message);

  ///
  Future<void> sendRequest(
      String topic, String method, Map<String, dynamic> params);

  ///
  Future<void> cleanup();

  ///
  Future<void> connectUser(DappConnectUser user);

  ///
  void closeConnection();
}

///
class DappConnectClient extends DappConnectClientProtocol {
  ///
  final Level logLevel;

  late final Logger logger = detachedLogger('📡');

  final LogHandlerFunction logHandlerFunction;

  /// Default logger for the [Web3MQClient].
  Logger detachedLogger(String name) => Logger.detached(name)
    ..level = logLevel
    ..onRecord.listen(logHandlerFunction);

  ///
  DappConnectClient(String apiKey, AppMetadata metadata,
      {this.logLevel = Level.ALL,
      this.logHandlerFunction = Web3MQLogger.defaultLogHandler,
      String? baseURL,
      IdGenerator? idGenerator,
      Storage? storage,
      KeyStorage? keyStorage,
      ShareKeyCoder? shareKeyCoder,
      Serializer? serializer,
      Web3MQWebSocket? ws})
      : _apiKey = apiKey,
        _appMetadata = metadata {
    _ws = ws ??
        Web3MQWebSocket(
          apiKey: apiKey,
          baseUrl: baseURL ?? TestnetEndpoint.sg1,
          handler: handleEvent,
          logger: detachedLogger('🔌'),
        );

    _idGenerator = idGenerator ?? DappConnectRequestIdGenerator();

    _storage = storage ?? Web3MQStorage();

    _shareKeyCoder = shareKeyCoder ?? DappConnectShareKeyCoder();

    _keyStorage = keyStorage ?? DappConnectKeyStorage();

    _serializer = serializer ?? Serializer(_keyStorage, _shareKeyCoder);
  }

  final _newMessageController = BehaviorSubject<DappConnectMessage>();

  /// Stream of new messages.
  Stream<DappConnectMessage> get newMessageStream =>
      _newMessageController.stream;

  final _newRequestController = BehaviorSubject<Request>();

  /// Stream of new [Request].
  Stream<Request> get newRequestStream => _newRequestController.stream;

  final _newResponseController = BehaviorSubject<Response>();

  /// Stream of new [Response].
  Stream<Response> get newResponseStream => _newResponseController.stream;

  void handleEvent(Event event) {
    switch (event.type) {
      case EventType.notificationMessageNew:
        break;
      case EventType.connectionChanged:
        break;
      case EventType.messageNew:
        final wsMessage = event.message;
        if (null == wsMessage) return;
        final message = Message.fromWSMessage(wsMessage);
        if (message.messageType != MessageType.bridge) {
          break;
        }
        final thePayload = message.payload;
        if (null != thePayload) {
          final json = jsonDecode(thePayload);
          final payload = MesasgePayload.fromJson(json);
          final dappMessage = DappConnectMessage(payload, message.from);
          _newMessageController.add(dappMessage);
          _onReceiveMessage(dappMessage);
        }
        break;
      default:
        break;
    }
  }

  final AppMetadata _appMetadata;

  final String _apiKey;

  late final IdGenerator _idGenerator;

  /// By default the Chat client will write all messages with level Warn or
  /// Error to stdout.
  late final Web3MQWebSocket _ws;

  late final KeyStorage _keyStorage;

  late final ShareKeyCoder _shareKeyCoder;

  late final Serializer _serializer;

  late final Storage _storage;

  @override
  Future<void> approveSessionProposal(String proposalId,
      Map<String, SessionNamespace> sessionNamespace, Duration expire) async {
    final proposal = await _storage.getSessionProposal(proposalId);
    if (proposal == null) {
      throw DappConnectError.proposalNotFound();
    }
    final theUser = currentUser;
    if (null == theUser) {
      throw DappConnectError.currentUserNotFound();
    }

    final privateKeyHex = await _keyStorage.privateKeyHex;
    final publicKeyHex =
        await KeyPairUtils.publicKeyHexFromPrivateKeyHex(privateKeyHex);

    // 1. send response
    // 2. remove proposal
    // 3. set session
    // 4. redirect to dapps
    final sessionProperties = SessionProperties.fromExpiryDuration(expire);

    final result = SessionProposalResult(
        sessionNamespace, sessionProperties, _appMetadata);
    final response = RPCResponse(proposalId,
        RequestMethod.providerAuthorization, result.toBytes(), null);

    _send(response.toBytes(), proposal.pairingTopic,
        proposal.proposer.publicKey, privateKeyHex);

    _storage.removeSessionProposal(proposalId);

    final session = Session(
        proposal.pairingTopic,
        theUser.userId,
        Participant(publicKeyHex, _appMetadata),
        proposal.proposer,
        sessionProperties.expiry,
        sessionNamespace);
    _storage.setSession(session);

    // TODO: redirect to dapp
  }

  @override
  Future<void> rejectSessionProposal(String proposalId) async {
    final proposal = await _storage.getSessionProposal(proposalId);
    if (proposal == null) {
      throw DappConnectError.proposalNotFound();
    }
    final theUser = currentUser;
    if (null == theUser) {
      throw DappConnectError.currentUserNotFound();
    }

    final response = RPCResponse(
        proposalId,
        RequestMethod.providerAuthorization,
        null,
        RPCError(code: 5000, message: 'User disapproved requested methods'));

    _send(response.toBytes(), proposal.pairingTopic,
        proposal.proposer.publicKey, theUser.sessionKey);
    // TODO: redirect to dapp
  }

  @override
  DappConnectURI createSessionProposalURI(
      Map<String, ProposalNamespace> requiredNamespaces) {
    final theUser = currentUser;
    if (null == theUser) {
      throw DappConnectError.currentUserNotFound();
    }
    final publicKey = theUser.sessionKey;
    final proposer = Participant(publicKey, _appMetadata);

    final proposalId = _idGenerator.next();
    final proposal = SessionProposalContent(
        requiredNamespaces, SessionProperties.fromDefault());
    final request = SessionProposalRPCRequest(
        proposalId, RequestMethod.providerAuthorization, proposal);
    return DappConnectURI(theUser.userId, proposer, request);
  }

  @override
  Future<void> deleteSession(String topic) async {
    _storage.removeSession(topic);
    _storage.removeRecord(topic);
  }

  @override
  // TODO: implement requestStream
  Stream<Request> get requestStream => throw UnimplementedError();

  @override
  // TODO: implement responseStream
  Stream<Response> get responseStream => throw UnimplementedError();

  @override
  Future<void> sendRequest(
      String topic, String method, Map<String, dynamic> params) async {
    final requestId = _idGenerator.next();
    // convert params to List<int>
    final rpcRequest = RPCRequest.from(requestId, method, params);
    _sendRequest(rpcRequest, topic);
  }

  @override
  Future<void> sendErrorResponse(
      Request request, int code, String message) async {
    final response = RPCResponse(
        request.id,
        RequestMethod.providerAuthorization,
        null,
        RPCError(code: code, message: message));
    await _sendResponse(response, request);
  }

  @override
  Future<void> sendSuccessResponse(
      Request request, Map<String, dynamic> result) async {
    // convert result to List<int>
    final messageJson = jsonEncode(result);
    final messageBytes = utf8.encode(messageJson);
    final response = RPCResponse(
        request.id, RequestMethod.providerAuthorization, messageBytes, null);
    await _sendResponse(response, request);
  }

  @override
  Future<List<Session>> get sessions => _storage.getAllSessions();

  ///
  Future<String> personalSign(String message, String address, String topic,
      {String? password}) async {
    final session = await _storage.getSession(topic);
    if (null == session) {
      throw DappConnectError.sessionNotFound();
    }
    final theUser = currentUser;
    if (null == theUser) {
      throw DappConnectError.currentUserNotFound();
    }
    final requestId = _idGenerator.next();
    final params = List<String>.from([message, address, password]);
    // convert params to List<int>
    final paramsJson = jsonEncode(params);
    final bytes = utf8.encode(paramsJson);
    RPCRequest(requestId, RequestMethod.personalSign, bytes);
    _send(bytes, topic, session.peerParticipant.publicKey, theUser.sessionKey);
    final response = await _waitingForResponse(requestId);
    final result = response.result;
    if (null != result) {
      return utf8.decode(result);
    } else {
      throw response.error ?? DappConnectError.unknown();
    }
  }

  @override
  Future<void> cleanup() async {
    // TODO: implement cleanup
  }

  @override
  Future<void> connectUser(DappConnectUser user) => _connectUser(user);

  /// Connects the user to the websocket.
  Future<DappConnectUser> _connectUser(DappConnectUser user) async {
    if (_ws.connectionCompleter?.isCompleted == false) {
      throw const Web3MQError(
        'User already getting connected, try calling `disconnectUser` '
        'before trying to connect again',
      );
    }

    logger.info('setting user : ${user.userId}');

    try {
      final connectedUser = await openConnection();
      return currentUser = connectedUser;
    } catch (e, stk) {
      logger.severe('error connecting user : ${user.userId}', e, stk);
      rethrow;
    }
  }

  StreamSubscription<ConnectionStatus>? _connectionStatusSubscription;

  final _wsConnectionStatusController =
      BehaviorSubject.seeded(ConnectionStatus.disconnected);

  set _wsConnectionStatus(ConnectionStatus status) =>
      _wsConnectionStatusController.add(status);

  /// The current status value of the [_ws] connection
  ConnectionStatus get wsConnectionStatus =>
      _wsConnectionStatusController.value;

  /// This notifies the connection status of the [_ws] connection.
  /// Listen to this to get notified when the [_ws] tries to reconnect.
  Stream<ConnectionStatus> get wsConnectionStatusStream =>
      _wsConnectionStatusController.stream.distinct();

  ///
  DappConnectUser? currentUser;

  /// Creates a new WebSocket connection with the current user.
  Future<DappConnectUser> openConnection() async {
    assert(currentUser != null, 'User is not set on client');

    final user = currentUser!;

    logger.info('Opening web-socket connection for ${user.userId}');

    if (wsConnectionStatus == ConnectionStatus.connecting) {
      throw Web3MQError('Connection already in progress for ${user.userId}');
    }

    if (wsConnectionStatus == ConnectionStatus.connected) {
      throw Web3MQError('Connection already available for ${user.userId}');
    }

    _wsConnectionStatus = ConnectionStatus.connecting;

    // skipping `ws` seed connection status -> ConnectionStatus.disconnected
    // otherwise `client.wsConnectionStatusStream` will emit in order
    // 1. ConnectionStatus.disconnected -> client seed status
    // 2. ConnectionStatus.connecting -> client connecting status
    // 3. ConnectionStatus.disconnected -> ws seed status
    _connectionStatusSubscription =
        _ws.connectionStatusStream.skip(1).listen(_connectionStatusHandler);

    try {
      await _ws.bridgeConnect(user);
      return user;
    } catch (e, stk) {
      logger.severe('error connecting ws', e, stk);
      rethrow;
    }
  }

  void _connectionStatusHandler(ConnectionStatus status) async {
    final event = Event(EventType.connectionChanged,
        nodeId: _ws.nodeId, connectionStatus: status);
    handleEvent(event);
  }

  @override
  void closeConnection() {
    if (wsConnectionStatus == ConnectionStatus.disconnected) return;

    logger.info('Closing web-socket connection for ${currentUser?.userId}');
    _wsConnectionStatus = ConnectionStatus.disconnected;

    _connectionStatusSubscription?.cancel();
    _connectionStatusSubscription = null;

    _ws.disconnect();
  }

  void _onReceiveMessage(DappConnectMessage message) async {
    final privateKey = await _keyStorage.privateKeyHex;
    final bytes = await _serializer.decrypt(
        message.payload.content, message.payload.publicKey, privateKey);
    final json = jsonDecode(utf8.decode(bytes));
    try {
      final rpcRequest = RPCRequest.fromJson(json);
      final request = Request.fromRpcRequest(
          rpcRequest, message.fromTopic, message.payload.publicKey);
      _onReceiveRequest(request);
    } catch (e) {
      try {
        final rpcResponse = RPCResponse.fromJson(json);
        final response = Response.fromRpcResponse(
            rpcResponse, message.fromTopic, message.payload.publicKey);
        _onReceiveResponse(response);
      } catch (e) {
        logger.warning('Unknown message type: $json');
      }
    }
  }

  void _onReceiveRequest(Request request) {
    _newRequestController.add(request);
    _storage.setRecord(Record.fromRequest(request));
  }

  void _onReceiveResponse(Response response) {
    _newResponseController.add(response);
    _storage.getRecord(response.topic).then((value) {
      if (null != value) {
        final fianlRecord = value.copyWith(response: response);
        _storage.setRecord(fianlRecord);
      }
    });
  }

  Future<Response> _waitingForResponse(String requestId) async {
    final completer = Completer<Response>();
    StreamSubscription<Response>? subscription;
    subscription = responseStream
        .timeout(Duration(minutes: 3), onTimeout: (sink) {
          sink.addError(DappConnectError.timeout);
        })
        .where((response) => response.id == requestId)
        .take(1)
        .listen((response) {
          subscription?.cancel();
          completer.complete(response);
        }, onError: (error) {
          subscription?.cancel();
          completer.completeError(error);
        }, cancelOnError: true);
    return completer.future;
  }

  void _bindEvent() {
    responseStream.listen((event) {});
  }

  Future<void> _sendResponse(RPCResponse response, Request request) async {
    final privateKey = await _keyStorage.privateKeyHex;
    final session = await _storage.getSession(request.topic);
    if (null == session) {
      throw DappConnectError.sessionNotFound();
    }
    await _send(response.toBytes(), session.topic,
        session.peerParticipant.publicKey, privateKey);
  }

  Future<void> _sendRequest(RPCRequest request, String topic) async {
    final privateKey = await _keyStorage.privateKeyHex;
    final session = await _storage.getSession(topic);
    if (null == session) {
      throw DappConnectError.sessionNotFound();
    }
    await _send(request.toBytes(), session.topic,
        session.peerParticipant.publicKey, privateKey);
  }

  Future<void> _send(List<int> bytes, String topic, String peerPublicKeyHex,
      String privateKeyHex) async {
    final theUser = currentUser;
    if (null == theUser) {
      throw DappConnectError.currentUserNotFound();
    }
    final encrypted =
        await _serializer.encrypt(bytes, peerPublicKeyHex, privateKeyHex);
    final keyPair = await KeyPairUtils.keyPairFromPrivateKeyHex(privateKeyHex);
    final publicKeyHex = await KeyPairUtils.publicKeyHexFromKeyPair(keyPair);
    final payload = MesasgePayload(encrypted, publicKeyHex);
    final message = DappConnectMessage(payload, theUser.userId);
    await _sendDappConnectMessage(
        message, topic, theUser.userId, privateKeyHex);
  }

  Future<void> _sendDappConnectMessage(DappConnectMessage message, String topic,
      String userId, String privateKeyHex) async {
    final wsMessage =
        await _convertToChatMessage(message, topic, userId, privateKeyHex);
    _ws.send(wsMessage);
  }

  Future<ChatMessage> _convertToChatMessage(DappConnectMessage message,
      String topic, String userId, String privateKeyHex) async {
    final messageJson = jsonEncode(message.toJson());
    final messageBytes = utf8.encode(messageJson);
    return await MessageFactory.fromBytes(
        messageBytes, topic, userId, privateKeyHex, _ws.nodeId);
  }
}