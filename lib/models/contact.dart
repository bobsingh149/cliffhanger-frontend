import 'user.dart';

class ContactModel {
  final String conversationId;
  final bool isGroup;
  final List<UserModel> users;
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
              ?.map((user) => UserModel.fromJson(user))
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

class ConversationInputModel {
  final String? conversationId;
  final bool isGroup;
  final List<String> members;
  final String userId;
  final String? groupName;
  final String? groupImage;

  ConversationInputModel({
    this.conversationId,
    required this.isGroup,
    required this.members,
    required this.userId,
    this.groupName,
    this.groupImage,
  });

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'isGroup': isGroup,
      'members': members,
      'userId': userId,
      'groupName': groupName,
      'groupImage': groupImage,
    };
  }
}
