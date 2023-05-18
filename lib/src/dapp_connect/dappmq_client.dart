import 'dart:async';

import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:web3mq/src/dapp_connect/model/app_metadata.dart';
import 'package:web3mq/src/dapp_connect/model/request.dart';
import 'package:web3mq/src/dapp_connect/model/response.dart';
import 'package:web3mq/src/dapp_connect/model/uri.dart';
import 'package:web3mq/src/logger/logger.dart';

import '../error/error.dart';
import '../models/models.dart';
import '../ws/models/connection_status.dart';
import '../ws/models/event.dart';
import '../ws/websocket.dart';
import 'model/namespace.dart';
import 'model/session.dart';
import 'model/user.dart';

///
abstract class DappConnectClientProtocol {
  ///
  List<Session> get sessions;

  ///
  Stream<Request> get requestStream;

  ///
  Stream<Response> get responseStream;

  ///
  void deleteSession(String topic);

  ///
  DappConnectURI createSessionProposalURI(
      Map<String, ProposalNamespace> requiredNamespaces);

  ///
  void approveSessionProposal(
      String proposalId, Map<String, SessionNamespace> sessionNamespace);

  ///
  void rejectSessionProposal(String proposalId);

  ///
  void sendSuccessResponse(Request request, Map<String, dynamic> result);

  ///
  void sendErrorResponse(Request request, int code, String message);

  ///
  void sendRequest(String topic, String method, Map<String, dynamic> params);

  ///
  void cleanup();

  ///
  void connectUser(DappConnectUser user);

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
      Web3MQWebSocket? ws}) {
    _ws = ws ??
        Web3MQWebSocket(
          apiKey: apiKey,
          baseUrl: baseURL ?? TestnetEndpoint.sg1,
          handler: handleEvent,
          logger: detachedLogger('🔌'),
        );
  }

  final _eventController = BehaviorSubject<Event>();

  /// Method called to add a new event to the [_eventController].
  void handleEvent(Event event) {
    switch (event.type) {
      case EventType.notificationMessageNew:
        break;
      case EventType.connectionChanged:
        break;
      case EventType.messageNew:
        break;
      default:
        break;
    }
    _eventController.add(event);
  }

  /// By default the Chat client will write all messages with level Warn or
  /// Error to stdout.
  late final Web3MQWebSocket _ws;

  @override
  void approveSessionProposal(
      String proposalId, Map<String, SessionNamespace> sessionNamespace) {
    // TODO: implement approveSessionProposal
  }

  @override
  DappConnectURI createSessionProposalURI(
      Map<String, ProposalNamespace> requiredNamespaces) {
    // TODO: implement createSessionProposalURI
    throw UnimplementedError();
  }

  @override
  void deleteSession(String topic) {
    // TODO: implement deleteSession
  }

  @override
  void rejectSessionProposal(String proposalId) {
    // TODO: implement rejectSessionProposal
  }

  @override
  // TODO: implement requestStream
  Stream<Request> get requestStream => throw UnimplementedError();

  @override
  // TODO: implement responseStream
  Stream<Response> get responseStream => throw UnimplementedError();

  @override
  void sendErrorResponse(Request request, int code, String message) {
    // TODO: implement sendErrorResponse
  }

  @override
  void sendRequest(String topic, String method, Map<String, dynamic> params) {
    // TODO: implement sendRequest
  }

  @override
  void sendSuccessResponse(Request request, Map<String, dynamic> result) {
    // TODO: implement sendSuccessResponse
  }

  @override
  // TODO: implement sessions
  List<Session> get sessions => throw UnimplementedError();

  Future<String> personalSign(String message, String address, String topic,
      {String? password}) {
    // TODO: implement personalSign
    throw UnimplementedError();
  }

  @override
  void cleanup() {
    // TODO: implement cleanup
  }

  @override
  void connectUser(DappConnectUser user) => _connectUser(user);

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
}
