enum NotificationType {
  all(value: ""),
  subscription(value: "subscription"),
  receivedFriendRequest(value: "system.friend_request"),
  sendFriendRequest(value: "system.agree_friend_request"),
  groupInvitation(value: "group_invitation"),
  provider(value: "provider.notification");

  const NotificationType({
    required this.value,
  });

  final String value;
}

enum ReadStatus {
  received,
  delivered,
  read,
}
