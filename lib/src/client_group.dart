part of 'client.dart';

extension ClientGroup on Web3MQClient {
  /// Retrieves a paginated list of groups.
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

  /// Retrieves the group information for the specified group ID.
  Future<Group> groupInfo(String groupId) async {
    return await _service.group.groupInfo(groupId);
  }
}
