import 'user_info.dart';

class ContactModel {
  final String conversationId;
  final bool isGroup;
  final List<UserInfoModel> users;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? groupName;
  final String? groupImage;

  ContactModel({
    required this.conversationId,
    required this.isGroup,
    required this.users,
    this.lastMessage,
    this.lastMessageTime,
    this.groupName,
    this.groupImage,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      conversationId: json['id'],
      isGroup: json['isGroup'] ?? false,
      users: (json['users'] as List?)
              ?.map((user) => UserInfoModel.fromJson(user))
              .toList() ??
          [],
      lastMessage: json['lastMessage'],
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime'])
          : null,
      groupName: json['groupName'],
      groupImage: json['groupImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': conversationId,
      'isGroup': isGroup,
      'users': users.map((user) => user.toJson()).toList(),
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'groupName': groupName,
      'groupImage': groupImage,
    };
  }

  String getDisplayName() {
    if (isGroup) {
      return groupName ?? 'Unnamed Group';
    }
    return users.isNotEmpty ? users[0].name : 'Unknown User';
  }

  String? getDisplayImage() {
    if (isGroup) {
      return groupImage;
    }
    return users.isNotEmpty ? users[0].profileImage : null;
  }
}
