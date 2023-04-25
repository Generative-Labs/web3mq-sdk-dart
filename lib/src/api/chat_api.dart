import 'package:web3mq/src/api/responses.dart';

import '../error/error.dart';
import '../http/http_client.dart';
import '../models/pagination.dart';
import '../signer.dart';

class ChatApi {
  /// Initialize a new user api
  ChatApi(this._client, this._signer);

  final Web3MQHttpClient _client;

  final Signer _signer;

  /// Queries messages from remote
  Future<Page<Message>> queryMessagesByTopic(
      String topic, TimestampPagination pagination,
      {String? threadId}) async {
    final signResult = await _signer.signatureForRequest(topic);
    final response =
        await _client.get("/api/messages/history/", queryParameters: {
      'threadid': threadId,
      'topic': topic,
      'before_timestamp': pagination.timestampBeforeOrEqual,
      'size': pagination.limit,
      'userid': signResult.userId,
      'web3mq_signature': signResult.signature,
      'timestamp': signResult.time.millisecondsSinceEpoch
    });
    final res = Web3MQListResponse<Message>.fromJson(
        response.data, (json) => Message.fromJson(json));
    if (res.code == 0) {
      return res.data;
    }
    throw Web3MQNetworkError.raw(code: res.code, message: res.message ?? "");
  }

  /// Queries messages from remote
  Future<Page<ChannelModel>> queryChannels(Pagination pagination) async {
    final signResult = await _signer.signatureForRequest(null);
    final response = await _client.get("/api/chats/", queryParameters: {
      'page': pagination.page,
      'size': pagination.size,
      'userid': signResult.userId,
      'web3mq_signature': signResult.signature,
      'timestamp': signResult.time.millisecondsSinceEpoch
    });
    final res = Web3MQListResponse<ChannelModel>.fromJson(
        response.data, (json) => ChannelModel.fromJson(json));
    if (res.code == 0) {
      return res.data;
    }
    throw Web3MQNetworkError.raw(code: res.code, message: res.message ?? "");
  }

  /// Add channel
  Future<void> addChannel(String topic, String topicType, String channelId,
      String channelType) async {
    final signResult = await _signer.signatureForRequest(topic + topicType);
    final response = await _client.post("/api/chats/", data: {
      'topic': topic,
      'topic_type': topicType,
      'chatid': channelId,
      'chat_type': channelType,
      'userid': signResult.userId,
      'web3mq_signature': signResult.signature,
      'timestamp': signResult.time.millisecondsSinceEpoch
    });
    final res = CommonResponse.fromJson(response.data);
    if (res.code == 0) {
      return;
    }
    throw Web3MQNetworkError.raw(code: res.code, message: res.message ?? "");
  }

  /// Marks all messages to read
  Future<void> markAllMessagesToRead(
      String topic, List<String> messageIds) async {
    final status = 'read';
    final signResult = await _signer.signatureForRequest(status);
    final response = await _client.post("/api/messages/status/", data: {
      'messages': messageIds,
      'topic': topic,
      'status': status,
      'userid': signResult.userId,
      'web3mq_signature': signResult.signature,
      'timestamp': signResult.time.millisecondsSinceEpoch
    });
    final res = CommonResponse.fromJson(response.data);
    if (res.code == 0) {
      return;
    }
    throw Web3MQNetworkError.raw(code: res.code, message: res.message ?? "");
  }

  /// Create thread
  Future<void> createThread(
      String topicId, String parentMessageId, String? threadName) async {
    final signResult =
        await _signer.signatureForRequest(topicId + parentMessageId);
    final response = await _client.post(
      '/api/messages/create_thread/',
      data: {
        'topicid': topicId,
        'threadid': parentMessageId,
        "userid": signResult.userId,
        "timestamp": signResult.time.millisecondsSinceEpoch,
        "web3mq_user_signature": signResult.signature
      },
    );
    final res = CommonResponse.fromJson(response.data);
    if (res.code == 0) {
      return;
    }
    throw Web3MQNetworkError.raw(code: res.code, message: res.message ?? "");
  }

  /// Get thread list by topic
  Future<List<Thread>> threadListByTopic(String topicId) async {
    final signResult = await _signer.signatureForRequest(topicId);
    final response =
        await _client.post('/api/messages/get_thread_list/', data: {
      'topicid': topicId,
      'userid': signResult.userId,
      'web3mq_user_signature': signResult.signature,
      'timestamp': signResult.time.millisecondsSinceEpoch
    });
    final res = Web3MQListResponse<Thread>.fromJson(
        response.data, (json) => Thread.fromJson(json));
    final theadList = res.data.result;
    if (res.code == 0) {
      return theadList;
    }
    throw Web3MQNetworkError.raw(code: res.code, message: res.message ?? "");
  }

  /// Get message list by thread
  Future<List<Message>> messageListByThreadId(String threadId) async {
    final signResult = await _signer.signatureForRequest(threadId);
    final response =
        await _client.post('/api/messages/get_thread_messages/', data: {
      'threadid': threadId,
      'userid': signResult.userId,
      'web3mq_user_signature': signResult.signature,
      'timestamp': signResult.time.millisecondsSinceEpoch
    });
    final res = Web3MQResponse<ThreadMessageListResponse>.fromJson(
        response.data, (json) => ThreadMessageListResponse.fromJson(json));
    final messageList = res.data?.result;
    if (res.code == 0 && null != messageList) {
      return messageList;
    }
    throw Web3MQNetworkError.raw(code: res.code, message: res.message ?? "");
  }

  /// Get all the missed events
  Future<Map<String, Map<String, String>>> sync(
    DateTime lastSyncAt,
  ) async {
    final signResult = await _signer
        .signatureForRequest(lastSyncAt.millisecondsSinceEpoch.toString());
    final response = await _client.post(
      '/api/get_new_messages/',
      data: {
        'sync_timestamp': lastSyncAt.millisecondsSinceEpoch,
        "userid": signResult.userId,
        "timestamp": signResult.time.millisecondsSinceEpoch,
        "web3mq_user_signature": signResult.signature
      },
    );
    final res = SyncResponse.fromJson(response.data);
    if (res.code == 0) {
      return res.data;
    }
    throw Web3MQNetworkError.raw(code: res.code, message: res.message ?? "");
  }
}
