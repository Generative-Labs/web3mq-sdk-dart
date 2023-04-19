import 'package:web3mq/src/api/responses.dart';
import 'package:web3mq/src/models/pagination.dart';

import '../error/error.dart';
import '../http/http_client.dart';
import '../signer.dart';

class GroupApi {
  /// Initializes a new GroupApi instance.
  GroupApi(this._client, this._signer);

  final Web3MQHttpClient _client;

  final Signer _signer;

  /// Retrieves a list of groups with optional pagination.
  Future<Page<Group>> groups(
      {Pagination pagination = const Pagination(page: 1, size: 30)}) async {
    final signResult = await _signer.signatureForRequest(null);
    final response = await _client.get("/api/groups/", queryParameters: {
      'page': pagination.page,
      'size': pagination.size,
      'userid': signResult.userId,
      'web3mq_signature': signResult.signature,
      'timestamp': signResult.time.millisecondsSinceEpoch
    });
    final res = Web3MQListResponse<Group>.fromJson(
        response.data, (json) => Group.fromJson(json));
    if (res.code == 0) {
      return res.data;
    }
    throw Web3MQNetworkError.raw(code: res.code, message: res.message ?? "");
  }

  /// Creates a new group with the specified name and avatar URL.
  Future<Group> createGroup(String name, String? avatarUrl) async {
    final signResult = await _signer.signatureForRequest(null);
    final response = await _client.post('/api/groups/', data: {
      'group_name': name,
      'avatar_url': avatarUrl,
      'userid': signResult.userId,
      'web3mq_signature': signResult.signature,
      'timestamp': signResult.time.millisecondsSinceEpoch
    });
    final res = Web3MQResponse<Group>.fromJson(
        response.data, (json) => Group.fromJson(json));
    final group = res.data;
    if (res.code == 0 && null != group) {
      return group;
    }
    throw Web3MQNetworkError.raw(code: res.code, message: res.message ?? "");
  }

  /// Retrieves a list of group members by group ID with optional pagination.
  Future<Page<Member>> membersByGroupId(String groupId,
      {Pagination pagination = const Pagination(page: 1, size: 30)}) async {
    final signResult = await _signer.signatureForRequest(groupId);
    final response = await _client.get("/api/group_members/", queryParameters: {
      'page': pagination.page,
      'size': pagination.size,
      'userid': signResult.userId,
      'web3mq_signature': signResult.signature,
      'timestamp': signResult.time.millisecondsSinceEpoch
    });
    final res = Web3MQListResponse<Member>.fromJson(
        response.data, (json) => Member.fromJson(json));
    if (res.code == 0) {
      return res.data;
    }
    throw Web3MQNetworkError.raw(code: res.code, message: res.message ?? "");
  }

  /// Invites the specified users to the given group by their user IDs.
  Future<void> invite(String groupId, List<String> userIds) async {
    final signResult = await _signer.signatureForRequest(groupId);
    final response = await _client.post("/api/group_invitation/", data: {
      'groupid': groupId,
      'members': userIds,
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

  /// Retrieves information for a specific group by its group ID.
  Future<Group> groupInfo(String groupId) async {
    final signResult = await _signer.signatureForRequest(groupId);
    final response = await _client.get("/api/group_info/", queryParameters: {
      'groupid': groupId,
      'userid': signResult.userId,
      'web3mq_user_signature': signResult.signature,
      'timestamp': signResult.time.millisecondsSinceEpoch
    });
    final res = Web3MQResponse<Group>.fromJson(
        response.data, (json) => Group.fromJson(json));
    final group = res.data;
    if (res.code == 0 && null != group) {
      return group;
    }
    throw Web3MQNetworkError.raw(code: res.code, message: res.message ?? "");
  }

  /// Updates the group permissions for the specified group.
  Future<void> updateGroupPermissions(
      String groupId, GroupPermission permission) async {
    final signResult = await _signer.signatureForRequest(groupId);
    final response =
        await _client.post("/api/update_group_permissions/", data: {
      'groupid': groupId,
      'permissions': {
        'group:join': {'type': 'enum', 'value': permission.value}
      },
      'userid': signResult.userId,
      'web3mq_user_signature': signResult.signature,
      'timestamp': signResult.time.millisecondsSinceEpoch
    });
    final res = CommonResponse.fromJson(response.data);
    if (res.code == 0) {
      return;
    }
    throw Web3MQNetworkError.raw(code: res.code, message: res.message ?? "");
  }

  /// Joins a group with the specified group ID.
  Future<void> joinGroup(String groupId) async {
    final signResult = await _signer.signatureForRequest(groupId);
    final response = await _client.post("/api/user_join_group/", data: {
      'groupid': groupId,
      'userid': signResult.userId,
      'web3mq_user_signature': signResult.signature,
      'timestamp': signResult.time.millisecondsSinceEpoch
    });
    final res = CommonResponse.fromJson(response.data);
    if (res.code == 0) {
      return;
    }
    throw Web3MQNetworkError.raw(code: res.code, message: res.message ?? "");
  }

  /// Quits a group with the specified group ID.
  Future<void> quitGroup(String groupId) async {
    final signResult = await _signer.signatureForRequest(groupId);
    final response = await _client.post("/api/quit_group/", data: {
      'groupid': groupId,
      'userid': signResult.userId,
      'web3mq_user_signature': signResult.signature,
      'timestamp': signResult.time.millisecondsSinceEpoch
    });
    final res = CommonResponse.fromJson(response.data);
    if (res.code == 0) {
      return;
    }
    throw Web3MQNetworkError.raw(code: res.code, message: res.message ?? "");
  }
}

enum GroupPermission {
  invite,
  public,
  nftValidation;

  String get value {
    switch (this) {
      case GroupPermission.invite:
        return 'ceator_invite_friends';
      case GroupPermission.public:
        return 'public';
      case GroupPermission.nftValidation:
        return 'nft_validation';
    }
  }
}
