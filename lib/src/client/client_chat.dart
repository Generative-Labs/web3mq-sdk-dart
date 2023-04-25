part of 'client.dart';

extension ClientChat on Web3MQClient {
  /// Fetches channels from local database.
  Future<List<ChannelState>> fetchChannelsFromLocalDatabase({
    Pagination paginationParams = const Pagination(page: 1, size: 50),
  }) async {
    final offlineChannels = (await _persistenceClient?.getChannelStates(
          paginationParams: paginationParams,
        )) ??
        [];
    final updatedData =
        _mapChannelStateToChannelModel(offlineChannels, state.channels);
    state.addChannels(updatedData.key);
    return updatedData.value;
  }

  /// Fetches channels from server.
  Future<List<ChannelState>> fetchChannelsFromServer(
      {Pagination paginationParams =
          const Pagination(page: 1, size: 50)}) async {
    final page = await _service.chat.queryChannels(paginationParams);
    final channels = page.result;

    final persistenceClient = _persistenceClient;
    if (null == persistenceClient) {
      return channels.map((e) => ChannelState(channel: e)).toList();
    }

    List<ChannelState> states = [];
    for (final channel in channels) {
      final aState =
          await persistenceClient.getChannelStateByTopic(channel.topic);
      states.add(aState);
    }

    final updateData = _mapChannelStateToChannelModel(states, state.channels);
    await persistenceClient
        .updateChannelQueries(channels.map((e) => e.topic).toList());

    state.addChannels(updateData.key);
    return updateData.value;
  }

  /// Fetches the list of channel states from local database or server
  Stream<List<ChannelState>> fetchChannels({
    Pagination paginationParams = const Pagination(page: 1, size: 50),
  }) async* {
    final hash = generateHash([
      paginationParams,
    ]);
    if (_queryChannelsStreams.containsKey(hash)) {
      yield await _queryChannelsStreams[hash]!;
    } else {
      final channels = await fetchChannelsFromLocalDatabase(
        paginationParams: paginationParams,
      );
      if (channels.isNotEmpty) yield channels;

      try {
        final newQueryChannelsFuture = fetchChannelsFromServer(
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
    List<ChannelModel> updatedChannels = [];

    Future.forEach(events.keys, (String channelId) async {
      bool hasUnread = false;
      Map<String, String> channelData = events[channelId]!;

      int unreadCount = 0;
      for (String messageId in channelData.keys) {
        String readStatus = channelData[messageId]!;

        if (readStatus != 'read') {
          totalUnreadCount++;
          hasUnread = true;
          unreadCount++;
        }
      }

      if (hasUnread) {
        unreadChannelCount++;
      }

      final channel = await persistenceClient.getChannelByTopic(channelId);
      if (channel != null) {
        final updatedChannel = channel.copyWith(
            unreadMessageCount: channel.unreadMessageCount + unreadCount);
        updatedChannels.add(updatedChannel);
      }
    }).then((_) {
      persistenceClient.updateChannels(updatedChannels);
      persistenceClient.updateConnectionInfo(Event(EventType.connectionChanged,
          unreadChannels: unreadChannelCount,
          totalUnreadCount: totalUnreadCount));
    });
  }

  MapEntry<Map<String, ChannelState>, List<ChannelState>>
      _mapChannelStateToChannelModel(
    List<ChannelState> channelStates,
    Map<String, ChannelState> currentState,
  ) {
    final channels = {...currentState};
    final newChannels = <ChannelState>[];
    for (final channelState in channelStates) {
      final channel = channels[channelState.channel!.channelId];
      if (channel != null) {
        newChannels.add(channel);
      } else {
        final newChannel = channelState;
        final channelId = newChannel.channel?.channelId;
        if (channelId != null) {
          channels[channelId] = newChannel;
          newChannels.add(newChannel);
        }
      }
    }
    return MapEntry(channels, newChannels);
  }
}