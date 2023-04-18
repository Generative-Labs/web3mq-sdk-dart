part of 'client.dart';

extension ClientGroup on Web3MQClient {
  /// Gets the group list
  Future<Page<Group>> groups(
      {Pagination pagination = const Pagination(page: 1, size: 30)}) async {
    return await _service.group.groups(pagination: pagination);
  }

  /// Creates a group
  Future<Group> createGroup(String name, String? avatarUrl) async {
    final group = await _service.group.createGroup(name, avatarUrl);
    // if create group success, should refresh channel list.
    if (null != group) {
      queryChannelsOnline();
    }
    return group;
  }

  /// Group member list
  Future<Page<Member>> membersByGroupId(String groupId,
      {Pagination pagination = const Pagination(page: 1, size: 30)}) async {
    return await _service.group
        .membersByGroupId(groupId, pagination: pagination);
  }

  /// Invites user
  Future<void> invite(String groupId, List<String> userIds) async {
    return await _service.group.invite(groupId, userIds);
  }

  /// Gets the group info
  Future<Group> groupInfo(String groupId) async {
    return await _service.group.groupInfo(groupId);
  }
}
