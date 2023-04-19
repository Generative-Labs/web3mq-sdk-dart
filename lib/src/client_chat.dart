part of 'client.dart';

extension ClientChat on Web3MQClient {
  /// Requests channels with a given query from the Persistence client.
  Future<List<ChannelModel>> queryChannelsOffline({
    Pagination paginationParams = const Pagination(page: 1, size: 30),
  }) async {
    final offlineChannels = (await _persistenceClient?.getChannelStates(
          paginationParams: paginationParams,
        )) ??
        [];

    final channels =
        offlineChannels.map((e) => e.channel).whereNotNull().toList();
    final updatedData = _mapChannelListToState(channels, state.channels);
    state.addChannels(updatedData.key);
    return updatedData.value;
  }

  /// Requests channels with a given query from the server.
  Future<List<ChannelModel>> queryChannelsOnline(
      {Pagination paginationParams =
          const Pagination(page: 1, size: 50)}) async {
    final page = await _service.chat.queryChannels(paginationParams);
    final channels = page.result;

    final updateData = _mapChannelListToState(channels, state.channels);

    await _persistenceClient
        ?.updateChannelQueries(channels.map((e) => e.topic).toList());

    state.addChannels(updateData.key);
    return updateData.value;
  }

  /// Requests channels with a given query.
  Stream<List<ChannelModel>> queryChannels({
    Pagination paginationParams = const Pagination(page: 1, size: 50),
  }) async* {
    final hash = generateHash([
      paginationParams,
    ]);
    if (_queryChannelsStreams.containsKey(hash)) {
      yield await _queryChannelsStreams[hash]!;
    } else {
      final channels = await queryChannelsOffline(
        paginationParams: paginationParams,
      );
      if (channels.isNotEmpty) yield channels;

      try {
        final newQueryChannelsFuture = queryChannelsOnline(
          paginationParams: paginationParams,
        ).whenComplete(() {
          _queryChannelsStreams.remove(hash);
        });

        _queryChannelsStreams[hash] = newQueryChannelsFuture;

        yield await newQueryChannelsFuture;
      } catch (_) {
        if (channels.isEmpty) rethrow;
      }
    }
  }

  /// Add a channel to the chat
  Future<void> addChannel(String topic, String topicType, String channelId,
      String channelType) async {
    return await _service.chat
        .addChannel(topic, topicType, channelId, channelType);
  }

  /// Sends text message to the given topic.
  Future<Message> sendText(
    String text,
    String topic, {
    String? threadId,
    String cipherSuite = 'NONE',
    bool needStore = true,
  }) async {
    final user = state.currentUser;
    final nodeId = state.currentNodeId;
    if (user == null || nodeId == null) {
      throw Web3MQError("Send message error: you should be connected first");
    }
    final chatMessage = await MessageFactory.fromText(
        text, topic, user.userId, user.sessionKey, nodeId,
        threadId: threadId, needStore: needStore, cipherSuite: cipherSuite);
    _ws.send(chatMessage);
    _eventController.add(Event.fromMessageSending(chatMessage.message));
    return Message.fromProtobufMessage(chatMessage.message);
  }

  /// Query for messages in local storage
  Future<List<Message>?> queryLocalMessagesByTopic(String topic) async {
    return await _persistenceClient?.getMessagesByTopic(topic);
  }

  /// Query for the messages in the given topic.
  Future<Page<Message>> queryMessagesByTopic(
      String topic, Pagination pagination,
      {String? threadId}) async {
    return await _service.chat
        .queryMessagesByTopic(topic, pagination, threadId: threadId);
  }

  /// Creates a thread in the given topic and message id.
  Future<void> createThread(
      String topicId, String messageId, String? threadName) async {
    return _service.chat.createThread(topicId, messageId, threadName);
  }

  /// Get the threads in the given topic.
  Future<List<Thread>> threadList(String topicId) async {
    return _service.chat.threadListByTopic(topicId);
  }

  /// Get the messages in the thread with the given thread id.
  Future<List<Message>> messageListByThreadId(String threadId) async {
    return _service.chat.messageListByThreadId(threadId);
  }

  /// Get the events missed while offline to sync the offline storage
  /// Will automatically fetch [topic] and [lastSyncedAt] if [persistenceEnabled]
  Future<void> sync() async {
    final persistenceClient = _persistenceClient;
    if (persistenceClient == null) return;

    final lastSyncAt = await persistenceClient.getLastSyncAt();
    if (null == lastSyncAt) {
      return;
    }
    try {
      final res = await _service.chat.sync(lastSyncAt);
      _countUnread(res, persistenceClient);
    } catch (e, stk) {
      logger.severe('Error during sync', e, stk);
    }
  }

  /// Marks all message in the given topic to read
  void markAllMessagesToReadByTopic(
      String topic, List<String> messageIds) async {
    _service.chat.markAllMessagesToRead(topic, messageIds);
    _persistenceClient?.markAllToReadByTopic(topic);
  }

  ///
  Future<Web3MQMessageStatusResp> waitingForSendingMessageResponse(
      String messageId, Duration timeoutDuration) {
    final completer = Completer<Web3MQMessageStatusResp>();
    final subscription = on(EventType.messageUpdated).listen((event) {
      final response = event.messageStatusResponse;
      if (null != response && response.messageId == messageId) {
        completer.complete(response);
      }
    });
    completer.future.timeout(Duration(seconds: 6), onTimeout: () {
      subscription.cancel();
      throw TimeoutException('messageStatusUpdated event timed out');
    }).then((_) {
      subscription.cancel();
    });
    return completer.future;
  }

  void _countUnread(Map<String, Map<String, String>> events,
      PersistenceClient persistenceClient) {
    int totalUnreadCount = 0;
    int unreadChannelCount = 0;

    for (String channelId in events.keys) {
      bool hasUnread = false;
      Map<String, String> channelData = events[channelId]!;

      for (String messageId in channelData.keys) {
        String readStatus = channelData[messageId]!;

        if (readStatus != 'read') {
          totalUnreadCount++;
          hasUnread = true;
        }
      }

      if (hasUnread) {
        unreadChannelCount++;
      }
    }

    persistenceClient.updateConnectionInfo(Event(EventType.connectionChanged,
        unreadChannels: unreadChannelCount,
        totalUnreadCount: totalUnreadCount));

    print('Total Unread Count: $totalUnreadCount');
    print('Unread Channel Count: $unreadChannelCount');
  }

  MapEntry<Map<String, ChannelModel>, List<ChannelModel>>
      _mapChannelListToState(
    List<ChannelModel> channelModels,
    Map<String, ChannelModel> currentState,
  ) {
    final channels = {...currentState};
    final newChannels = <ChannelModel>[];
    for (final channelModel in channelModels) {
      final channel = channels[channelModel.topic];
      if (channel != null) {
        newChannels.add(channel);
      } else {
        channels[channelModel.topic] = channelModel;
        newChannels.add(channelModel);
      }
    }
    return MapEntry(channels, newChannels);
  }
}
