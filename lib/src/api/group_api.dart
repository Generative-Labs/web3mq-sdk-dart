import 'package:web3mq/src/api/responses.dart';
import 'package:web3mq/src/models/pagination.dart';

import '../error/error.dart';
import '../http/http_client.dart';
import '../signer.dart';

class GroupApi {
  /// Initialize a new group api
  GroupApi(this._client, this._signer);

  final Web3MQHttpClient _client;

  final Signer _signer;

  /// Gets the group list
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

  /// Creates a group
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

  /// Group member list
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

  /// Invites user
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

  /// Gets the group info
  Future<Group> groupInfo(String groupId) async {
    final signResult = await _signer.signatureForRequest(groupId);
    final response = await _client.post("/api/group_info/", data: {
      'groupid': groupId,
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
}
