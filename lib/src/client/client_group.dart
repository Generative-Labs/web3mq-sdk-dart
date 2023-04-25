part of 'client.dart';

extension ClientGroup on Web3MQClient {
  /// Retrieves a paginated list of groups which you joined in.
  Future<Page<Group>> groups(
          {Pagination pagination =
              const Pagination(page: 1, size: 30)}) async =>
      await _service.group.groups(pagination: pagination);

  /// Creates a group and returns a Group object.
  ///
  /// [groupName] is the name of the group.
  /// [avatarUrl] is the URL of the group's avatar.
  /// [permissions] are the permissions of the group [GroupPermission]. Defaults to public.
  Future<Group> createGroup(String name, String? avatarUrl,
      {GroupPermission permission = GroupPermission.public}) async {
    final group = await _service.group.createGroup(name, avatarUrl);
    // if create group success, should refresh channel list.
    fetchChannelsFromServer();
    return group;
  }

  /// Retrieves a paginated list of group members by the specified group ID.
  Future<Page<Member>> membersByGroupId(String groupId,
          {Pagination pagination =
              const Pagination(page: 1, size: 30)}) async =>
      _service.group.membersByGroupId(groupId, pagination: pagination);

  /// Invites the specified users to the specified group.
  Future<void> invite(String groupId, List<String> userIds) async =>
      _service.group.invite(groupId, userIds);

  /// Retrieves information for a specific group by its group ID.
  Future<Group> groupInfo(String groupId) async =>
      _service.group.groupInfo(groupId);

  /// Updates the group permissions for the specified group.
  Future<void> updateGroupPermissions(
          String groupId, GroupPermission permission) async =>
      _service.group.updateGroupPermissions(groupId, permission);

  /// Joins a group with the specified group ID.
  Future<void> joinGroup(String groupId) async {
    await _service.group.joinGroup(groupId);
    // if join group success, should refresh channel list.
    fetchChannelsFromServer();
  }

  /// Quits a group with the specified group ID.
  Future<void> quitGroup(String groupId) async {
    await _service.group.quitGroup(groupId);
    // if quit group success, should refresh channel list.
    fetchChannelsFromServer();
  }
}