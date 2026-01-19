import '../proto/agentassist.pb.dart' as pb;

class DisplayOnlineUser {
  final String serverId;
  final String serverName;
  final pb.OnlineUser user;

  const DisplayOnlineUser({
    required this.serverId,
    required this.serverName,
    required this.user,
  });

  String get key => '$serverId|${user.clientId}';

  String get displayNickname {
    if (user.nickname.isNotEmpty) return user.nickname;
    if (user.clientId.length >= 8) {
      return 'User_${user.clientId.substring(0, 8)}';
    }
    return 'User_${user.clientId}';
  }

  String get displayTitle => '$displayNickname@$serverName';
}
