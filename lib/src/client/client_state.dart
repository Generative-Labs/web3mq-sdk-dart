import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:web3mq/src/api/responses.dart';
import 'package:web3mq/src/models/channel_state.dart';

import '../utils/signer.dart';
import '../ws/models/pb/message.pb.dart';
import '../ws/models/ws_models.dart';
import 'client.dart';

class ClientState {
  /// Creates a new instance listening to events and updating the state
  ClientState(this._client, this._signer);

  CompositeSubscription? _eventsSubscription;

  final Web3MQClient _client;

  final Signer _signer;

  /// The current unread channels count
  int get unreadChannels => _unreadChannelsController.value;

  /// The current unread channels count as a stream
  Stream<int> get unreadChannelsStream => _unreadChannelsController.stream;

  /// The current total unread messages count
  int get totalUnreadCount => _totalUnreadCountController.value;

  /// The current total unread messages count as a stream
  Stream<int> get totalUnreadCountStream => _totalUnreadCountController.stream;

  /// The current list of channels in memory as a stream
  Stream<Map<String, ChannelState>> get channelsStream =>
      _channelsController.stream;

  /// The current list of channels in memory
  Map<String, ChannelState> get channels => _channelsController.value;

  /// The current user as a stream
  Stream<User?> get currentUserStream => _currentUserController.stream;

  /// Used internally for optimistic update of unread count
  set totalUnreadCount(int unreadCount) {
    _totalUnreadCountController.add(unreadCount);
  }

  /// Used internally for optimistic update of unread count
  set unreadChannelsCount(int unreadChannelsCount) {
    _unreadChannelsController.add(unreadChannelsCount);
  }

  set channels(Map<String, ChannelState> newChannels) {
    // sort by last message at
    List<MapEntry<String, ChannelState>> sortedChannels = newChannels.entries
        .toList()
      ..sort((a, b) => (b.value.channel?.lastMessageAt ?? DateTime(0))
          .compareTo(a.value.channel?.lastMessageAt ?? DateTime(0)));
    Map<String, ChannelState> sortedMap = Map.fromEntries(sortedChannels);
    _channelsController.add(sortedMap);
  }

  /// Adds a list of channels to the current list of cached channels
  void addChannels(Map<String, ChannelState> channelMap) {
    final newChannels = {
      ...channels,
      ...channelMap,
    };
    channels = newChannels;
  }

  /// Starts listening to the client events.
  void subscribeToEvents() {
    if (_eventsSubscription != null) {
      cancelEventSubscription();
    }
    _eventsSubscription = CompositeSubscription();

    _eventsSubscription!
      ..add(_client
          .on()
          .map((event) => event.unreadChannels)
          .whereType<int>()
          .listen((count) {
        _unreadChannelsController.add(count);
      }))
      ..add(_client
          .on()
          .map((event) => event.totalUnreadCount)
          .whereType<int>()
          .listen((count) {
        _totalUnreadCountController.add(count);
      }));

    _listenAllChannelsRead();

    _listenChannelDeleted();

    _listenMessageAdd();

    _listenMessageUpdated();
  }

  /// Stops listening to the client events.
  void cancelEventSubscription() {
    if (_eventsSubscription != null) {
      _eventsSubscription!.cancel();
      _eventsSubscription = null;
    }
  }

  /// Pauses listening to the client events.
  void pauseEventSubscription([Future<void>? resumeSignal]) {
    _eventsSubscription?.pause(resumeSignal);
  }

  void _listenAllChannelsRead() {
    _eventsSubscription?.add(
      _client.on(EventType.markRead).listen((event) {
        if (event.topicId == null) {
          // TODO: handle the channel read notification
          // channels.forEach((key, value) {
          //   // _unreadChannelsController.add(event)
          // });
        }
      }),
    );
  }

  void _listenChannelDeleted() {
    _eventsSubscription?.add(
      _client
          .on(
        EventType.channelDeleted,
      )
          .listen((Event event) async {
        final topic = event.topicId!;

        // remove from memory
        channels.remove(topic);

        // remove from persistence
        await _client.persistenceClient?.deleteChannels([topic]);
      }),
    );
  }

  void _updateLastSync(int timestamp) {
    _client.persistenceClient
        ?.updateLastSyncAt(DateTime.fromMillisecondsSinceEpoch(timestamp));
  }

  void _listenMessageAdd() {
    _eventsSubscription?.add(
      _client.on(EventType.messageNew).listen((Event event) async {
        final wsMessage = event.message;
        if (null == wsMessage) return;
        final message = Message.fromWSMessage(wsMessage)
            .copyWith(sendingStatus: MessageSendingStatus.sent);
        _updateByMessageIfNeeded(message);
        _updateLastSync(message.timestamp);
      }),
    );
    _eventsSubscription?.add(
      _client.on(EventType.messageSending).listen((Event event) async {
        final wsMessage = event.message;
        if (null == wsMessage) return;
        final message = Message.fromWSMessage(wsMessage)
            .copyWith(sendingStatus: MessageSendingStatus.sending);
        _updateByMessageIfNeeded(message);
      }),
    );
  }

  void _listenMessageUpdated() {
    _eventsSubscription
        ?.add(_client.on(EventType.messageUpdated).listen((event) {
      final status = event.messageStatusResponse;
      if (null == status) return;
      _client.persistenceClient?.getMessageById(status.messageId).then((value) {
        if (null == value) return;
        final finalMessage = value.copyWith(
            sendingStatus: convertMessageStatusToSendingStatus(status));
        //
        _updateByMessageIfNeeded(finalMessage);
      });
    }));
  }

  MessageSendingStatus convertMessageStatusToSendingStatus(
      Web3MQMessageStatusResp messageStatusResp) {
    if (messageStatusResp.messageStatus == 'received') {
      return MessageSendingStatus.sent;
    } else {
      return MessageSendingStatus.failed;
    }
  }

  void _updateByMessageIfNeeded(Message message) {
    // if there's no channel exist for this message, create a new one
    final channelId = message.topic;

    ChannelState channelState;
    if (channels.keys.contains(channelId)) {
      channelState = channels[channelId]!;
      if (_countMessageAsUnread(message)) {
        channelState.channel?.unreadMessageCount += 1;
      }
    } else {
      final channelModel = _createChannelModelByMessage(message);
      channelState = ChannelState(channel: channelModel, messages: [message]);
    }

    // update the last message
    channelState.channel?.lastMessageAt = DateTime.fromMillisecondsSinceEpoch(
      message.timestamp,
    );

    // add the channel to the channel list
    addChannels({channelId: channelState});

    // update the channel persistence if needed
    _client.persistenceClient?.updateChannelState(channelState);
  }

  String _channelTypeByTopic(String topic) {
    return topic.contains('user')
        ? 'user'
        : topic.contains('group')
            ? 'group'
            : 'topic';
  }

  ChannelModel _createChannelModelByMessage(Message message) {
    final channelId = message.topic;
    final channelType = _channelTypeByTopic(message.topic);
    final channelName = channelId;

    /// count unread count
    final unreadCount = _countMessageAsUnread(message) ? 1 : 0;

    // update channel(optional)
    _client.addChannel(channelId, channelType, channelId, channelType);

    return ChannelModel(
        channelId,
        channelType,
        channelId,
        channelType,
        channelName,
        null,
        DateTime.fromMillisecondsSinceEpoch(message.timestamp),
        null,
        unreadMessageCount: unreadCount);
  }

  ///
  String? get currentNodeId => _currentNodeIdController.valueOrNull;

  ///
  Stream<String?> get currentNodeIdStream => _currentNodeIdController.stream;

  /// The current user
  User? get currentUser => _currentUserController.valueOrNull;

  final _currentNodeIdController = BehaviorSubject<String?>();

  /// Sets the current node id
  set currentNodeId(String? nodeId) {
    _currentNodeIdController.add(nodeId);
  }

  /// Sets the user currently interacting with the client
  /// note: this fully overrides the [currentUser]
  set currentUser(User? user) {
    _currentUserController.add(user);
    _signer.updateUser(user);
    _setupAdditionalHeadersOnCurrentUserUpdate(user);
  }

  Future<void> _setupAdditionalHeadersOnCurrentUserUpdate(User? user) async {
    if (null == user) {
      Web3MQClient.additionalHeaders = {};
    } else {
      final publicHex = await user.publicKey;
      Web3MQClient.additionalHeaders = {
        "api-version": 2,
        "web3mq-request-pubkey": publicHex,
        "didkey": "${user.did.type}:${user.did.value}"
      };
    }
  }

  final _channelsController =
      BehaviorSubject<Map<String, ChannelState>>.seeded({});
  final _currentUserController = BehaviorSubject<User?>();
  final _unreadChannelsController = BehaviorSubject<int>.seeded(0);
  final _totalUnreadCountController = BehaviorSubject<int>.seeded(0);

  bool _countMessageAsUnread(Message message) {
    return message.sendingStatus == MessageSendingStatus.sent &&
        message.from != currentUser?.userId &&
        message.messageStatus?.status != 'read';
  }

  void dispose() {
    _currentUserController.close();
    _currentNodeIdController.close();
    _unreadChannelsController.close();
    _totalUnreadCountController.close();
    _channelsController.close();
  }
}
