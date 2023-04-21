// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'responses.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Web3MQResponse<T> _$Web3MQResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    Web3MQResponse<T>(
      json['code'] as int,
      json['msg'] as String?,
      _$nullableGenericFromJson(json['data'], fromJsonT),
    );

Map<String, dynamic> _$Web3MQResponseToJson<T>(
  Web3MQResponse<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.message,
      'data': _$nullableGenericToJson(instance.data, toJsonT),
    };

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) =>
    input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) =>
    input == null ? null : toJson(input);

Page<T> _$PageFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    Page<T>(
      json['total_count'] as int? ?? 0,
      (json['data_list'] as List<dynamic>?)?.map(fromJsonT).toList() ?? [],
    );

Map<String, dynamic> _$PageToJson<T>(
  Page<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'total_count': instance.total,
      'data_list': instance.result.map(toJsonT).toList(),
    };

Web3MQListResponse<T> _$Web3MQListResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    Web3MQListResponse<T>(
      json['code'] as int,
      json['msg'] as String?,
      Page<T>.fromJson(
          json['data'] as Map<String, dynamic>, (value) => fromJsonT(value)),
    );

Map<String, dynamic> _$Web3MQListResponseToJson<T>(
  Web3MQListResponse<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.message,
      'data': instance.data,
    };

CommonResponse _$CommonResponseFromJson(Map<String, dynamic> json) =>
    CommonResponse(
      json['code'] as int,
      json['msg'] as String?,
      json['data'],
    );

Map<String, dynamic> _$CommonResponseToJson(CommonResponse instance) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.message,
      'data': instance.data,
    };

ErrorResponse _$ErrorResponseFromJson(Map<String, dynamic> json) =>
    ErrorResponse(
      json['code'] as int,
      json['msg'] as String?,
      json['data'],
    );

Map<String, dynamic> _$ErrorResponseToJson(ErrorResponse instance) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.message,
      'data': instance.data,
    };

MySubscribeTopicsResponse _$MySubscribeTopicsResponseFromJson(
        Map<String, dynamic> json) =>
    MySubscribeTopicsResponse(
      json['code'] as int,
      json['msg'] as String?,
      (json['data'] as List<dynamic>)
          .map((e) => Topic.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MySubscribeTopicsResponseToJson(
        MySubscribeTopicsResponse instance) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.message,
      'data': instance.data,
    };

NotificationPayload _$NotificationPayloadFromJson(Map<String, dynamic> json) =>
    NotificationPayload(
      json['title'] as String,
      json['content'] as String,
      json['type'] as String,
      json['version'] as int,
      _dateTimeFromJson(json['timestamp'] as int),
    );

Map<String, dynamic> _$NotificationPayloadToJson(
        NotificationPayload instance) =>
    <String, dynamic>{
      'title': instance.title,
      'content': instance.content,
      'type': instance.type,
      'version': instance.version,
      'timestamp': instance.timestamp.toIso8601String(),
    };

NotificationQueryResponse _$NotificationQueryResponseFromJson(
        Map<String, dynamic> json) =>
    NotificationQueryResponse(
      json['cipher_suite'] as String,
      json['from'] as String,
      json['from_sign'] as String,
      json['messageid'] as String,
      NotificationPayload.fromJson(json['payload'] as Map<String, dynamic>),
      json['payload_type'] as String,
      json['status'] as String,
      json['topic'] as String,
    );

Map<String, dynamic> _$NotificationQueryResponseToJson(
        NotificationQueryResponse instance) =>
    <String, dynamic>{
      'cipher_suite': instance.cipherSuite,
      'from': instance.from,
      'from_sign': instance.fromSign,
      'messageid': instance.messageId,
      'payload': instance.payload,
      'payload_type': instance.payloadType,
      'status': instance.status,
      'topic': instance.topic,
    };

Topic _$TopicFromJson(Map<String, dynamic> json) => Topic(
      json['topicid'] as String,
      json['topic_name'] as String,
      json['create_at'] as int?,
    );

Map<String, dynamic> _$TopicToJson(Topic instance) => <String, dynamic>{
      'topicid': instance.topicId,
      'topic_name': instance.name,
      'create_at': instance.creationTime,
    };

UserInfo _$UserInfoFromJson(Map<String, dynamic> json) => UserInfo(
      json['did_type'] as String,
      json['did_value'] as String,
      json['userid'] as String,
      json['main_pubkey'] as String?,
      json['pubkey'] as String?,
      json['pubkey_type'] as String?,
      json['wallet_address'] as String?,
      json['wallet_type'] as String?,
      json['signature_content'] as String?,
      json['did_signature'] as String?,
      json['timestamp'] as int?,
    );

Map<String, dynamic> _$UserInfoToJson(UserInfo instance) => <String, dynamic>{
      'did_type': instance.didType,
      'did_value': instance.didValue,
      'userid': instance.userId,
      'main_pubkey': instance.mainKey,
      'pubkey': instance.pubKey,
      'pubkey_type': instance.pubKeyType,
      'wallet_address': instance.walletAddress,
      'wallet_type': instance.walletType,
      'signature_content': instance.signatureContent,
      'did_signature': instance.didSignature,
      'timestamp': instance.timestamp,
    };

UserRegisterResponse _$UserRegisterResponseFromJson(
        Map<String, dynamic> json) =>
    UserRegisterResponse(
      json['userid'] as String,
      json['did_value'] as String,
      json['did_type'] as String,
    );

Map<String, dynamic> _$UserRegisterResponseToJson(
        UserRegisterResponse instance) =>
    <String, dynamic>{
      'userid': instance.userId,
      'did_value': instance.didValue,
      'did_type': instance.didType,
    };

UserLoginResponse _$UserLoginResponseFromJson(Map<String, dynamic> json) =>
    UserLoginResponse(
      json['userid'] as String,
      json['did_value'] as String,
      json['did_type'] as String,
    );

Map<String, dynamic> _$UserLoginResponseToJson(UserLoginResponse instance) =>
    <String, dynamic>{
      'userid': instance.userId,
      'did_value': instance.didValue,
      'did_type': instance.didType,
    };

ChannelModel _$ChannelModelFromJson(Map<String, dynamic> json) => ChannelModel(
      json['topic'] as String,
      json['topic_type'] as String,
      json['chatid'] as String,
      json['chat_type'] as String,
      json['chat_name'] as String,
      json['avatar_url'] as String?,
      json['last_message_at'] == null
          ? null
          : DateTime.parse(json['last_message_at'] as String),
      json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      unreadMessageCount: json['unread_message_count'] as int?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ChannelModelToJson(ChannelModel instance) =>
    <String, dynamic>{
      'topic': instance.topic,
      'topic_type': instance.topicType,
      'chatid': instance.channelId,
      'chat_type': instance.channelType,
      'chat_name': instance.name,
      'avatar_url': instance.avatarUrl,
      'last_message_at': readonly(instance.lastMessageAt),
      'deleted_at': readonly(instance.deletedAt),
      'created_at': readonly(instance.createdAt),
      'updated_at': readonly(instance.updatedAt),
      'unread_message_count': readonly(instance.unreadMessageCount),
    };

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      userId: json['userid'] as String,
      nickname: json['nickname'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'userid': instance.userId,
      'nickname': instance.nickname,
      'avatar_url': instance.avatarUrl,
      'created_at': readonly(instance.createdAt),
      'updated_at': readonly(instance.updatedAt),
    };

Member _$MemberFromJson(Map<String, dynamic> json) => Member(
      json['userid'] as String,
      json['nickname'] as String?,
      json['avatar_url'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$MemberToJson(Member instance) => <String, dynamic>{
      'userid': instance.userId,
      'nickname': instance.nickName,
      'avatar_url': instance.avatarUrl,
      'createdAt': readonly(instance.createdAt),
      'updatedAt': readonly(instance.updatedAt),
    };

Notification _$NotificationFromJson(Map<String, dynamic> json) => Notification(
      json['messageId'] as String,
      (json['payload'] as List<dynamic>).map((e) => e as int).toList(),
      json['payloadType'] as String,
      json['comeFrom'] as String,
      json['fromSign'] as String,
      json['cipherSuite'] as String,
      json['timestamp'] as int,
      json['read'] as bool?,
      json['readTimestamp'] as int?,
      json['contentTopic'] as String,
    );

Map<String, dynamic> _$NotificationToJson(Notification instance) =>
    <String, dynamic>{
      'messageId': instance.id,
      'payload': instance.payload,
      'payloadType': instance.payloadType,
      'comeFrom': instance.userId,
      'fromSign': instance.signature,
      'contentTopic': instance.topicId,
      'cipherSuite': instance.cipherSuite,
      'timestamp': instance.timestamp,
      'read': instance.read,
      'readTimestamp': instance.readTimestamp,
    };

MessageStatus _$MessageStatusFromJson(Map<String, dynamic> json) =>
    MessageStatus(
      json['status'] as String?,
      json['timestamp'] as int?,
    );

Map<String, dynamic> _$MessageStatusToJson(MessageStatus instance) =>
    <String, dynamic>{
      'status': instance.status,
      'timestamp': instance.timestamp,
    };

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      json['topic'] as String,
      json['from'] as String,
      json['cipher_suite'] as String,
      json['messageid'] as String,
      json['timestamp'] as int,
      json['message_status'] == null
          ? null
          : MessageStatus.fromJson(
              json['message_status'] as Map<String, dynamic>),
      json['user'] == null
          ? null
          : UserModel.fromJson(json['user'] as Map<String, dynamic>),
      json['text'] as String?,
      json['threadid'] as String?,
      json['message_type'] as String?,
      (json['extra_data'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      sendingStatus: $enumDecodeNullable(
          _$MessageSendingStatusEnumMap, json['sending_status']),
      payload: json['payload'] as String?,
    );

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'topic': instance.topic,
      'from': instance.from,
      'cipher_suite': instance.cipherSuite,
      'messageid': instance.messageId,
      'message_type': instance.messageType,
      'timestamp': instance.timestamp,
      'payload': instance.payload,
      'threadid': instance.threadId,
      'extra_data': instance.extraData,
      'message_status': instance.messageStatus,
      'sending_status': readonly(instance.sendingStatus),
      'user': readonly(instance.user),
      'text': readonly(instance.text),
      'created_at': readonly(instance.createdAt),
      'updated_at': readonly(instance.updatedAt),
    };

const _$MessageSendingStatusEnumMap = {
  MessageSendingStatus.sending: 'sending',
  MessageSendingStatus.failed: 'failed',
  MessageSendingStatus.sent: 'sent',
};

SyncResponse _$SyncResponseFromJson(Map<String, dynamic> json) => SyncResponse(
      json['code'] as int,
      json['msg'] as String?,
      (json['data'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, Map<String, String>.from(e as Map)),
      ),
    );

Map<String, dynamic> _$SyncResponseToJson(SyncResponse instance) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.message,
      'data': instance.data,
    };

FollowUser _$FollowUserFromJson(Map<String, dynamic> json) => FollowUser(
      json['userid'] as String,
      json['follow_status'] as String,
      json['wallet_address'] as String?,
      json['wallet_type'] as String?,
      json['avatar_url'] as String?,
      json['nickname'] as String?,
    );

Map<String, dynamic> _$FollowUserToJson(FollowUser instance) =>
    <String, dynamic>{
      'userid': instance.userId,
      'follow_status': instance.followStatus,
      'wallet_address': instance.walletAddress,
      'wallet_type': instance.walletType,
      'avatar_url': instance.avatarUrl,
      'nickname': instance.nickname,
    };

Thread _$ThreadFromJson(Map<String, dynamic> json) => Thread(
      json['threadid'] as String,
      json['topicid'] as String,
      json['userid'] as String,
      json['thread_name'] as String?,
      json['timestamp'] as int,
    );

Map<String, dynamic> _$ThreadToJson(Thread instance) => <String, dynamic>{
      'threadid': instance.threadId,
      'topicid': instance.topicId,
      'userid': instance.userId,
      'thread_name': instance.threadName,
      'timestamp': instance.timestamp,
    };

ThreadListResponse _$ThreadListResponseFromJson(Map<String, dynamic> json) =>
    ThreadListResponse(
      (json['thread_list'] as List<dynamic>)
          .map((e) => Thread.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['total_count'] as int,
    );

Map<String, dynamic> _$ThreadListResponseToJson(ThreadListResponse instance) =>
    <String, dynamic>{
      'thread_list': instance.threadList,
      'total_count': instance.count,
    };

ThreadMessageListResponse _$ThreadMessageListResponseFromJson(
        Map<String, dynamic> json) =>
    ThreadMessageListResponse(
      json['total'] as int,
      (json['result'] as List<dynamic>)
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ThreadMessageListResponseToJson(
        ThreadMessageListResponse instance) =>
    <String, dynamic>{
      'total': instance.total,
      'result': instance.result,
    };

Group _$GroupFromJson(Map<String, dynamic> json) => Group(
      json['groupid'] as String,
      json['avatar_url'] as String?,
      json['group_name'] as String?,
    );

Map<String, dynamic> _$GroupToJson(Group instance) => <String, dynamic>{
      'groupid': instance.groupId,
      'avatar_url': instance.avatarUrl,
      'group_name': instance.groupName,
    };
