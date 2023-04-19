part of 'client.dart';

extension ClientGroup on Web3MQClient {
  /// Retrieves a paginated list of groups which you joined in.
  Future<Page<Group>> groups(
      {Pagination pagination = const Pagination(page: 1, size: 30)}) async {
    return await _service.group.groups(pagination: pagination);
  }

  /// Creates a new group with the specified name and avatar URL.
  /// Upon successful creation, refreshes the channel list.
  Future<Group> createGroup(String name, String? avatarUrl) async {
    final group = await _service.group.createGroup(name, avatarUrl);
    // if create group success, should refresh channel list.
    queryChannelsOnline();
    return group;
  }

  /// Retrieves a paginated list of group members by the specified group ID.
  Future<Page<Member>> membersByGroupId(String groupId,
      {Pagination pagination = const Pagination(page: 1, size: 30)}) async {
    return await _service.group
        .membersByGroupId(groupId, pagination: pagination);
  }

  /// Invites the specified users to the specified group.
  Future<void> invite(String groupId, List<String> userIds) async {
    return await _service.group.invite(groupId, userIds);
  }

  /// Retrieves information for a specific group by its group ID.
  Future<Group> groupInfo(String groupId) async {
    return await _service.group.groupInfo(groupId);
  }

  /// Updates the group permissions for the specified group.
  Future<void> updateGroupPermissions(
      String groupId, GroupPermission permission) async {
    return await _service.group.updateGroupPermissions(groupId, permission);
  }

  /// Joins a group with the specified group ID.
  Future<void> joinGroup(String groupId) async {
    await _service.group.joinGroup(groupId);
    // if join group success, should refresh channel list.
    queryChannelsOnline();
  }

  /// Quits a group with the specified group ID.
  Future<void> quitGroup(String groupId) async {
    await _service.group.quitGroup(groupId);
    // if quit group success, should refresh channel list.
    queryChannelsOnline();
  }
}
