import 'user.dart';

class ContactModel {
  final String conversationId;
  final bool isGroup;
  final List<UserModel> users;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? groupName;
  final String? groupImage;
  final UserModel? userResponse;

  ContactModel({
    required this.conversationId,
    required this.isGroup,
    required this.users,
    this.lastMessage,
    this.lastMessageTime,
    this.groupName,
    this.groupImage,
    this.userResponse,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    ContactModel contact = ContactModel(
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
      userResponse: json['userResponse'] != null
          ? UserModel.fromJson(json['userResponse'])
          : null,
    );
    if (contact.userResponse != null) {
      contact.users.add(contact.userResponse!);
    }
    return contact;
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
      'userResponse': userResponse?.toJson(),
    };
  }

  String getDisplayName() {
    if (isGroup) {
      return groupName ?? 'Unnamed Group';
    }
    return userResponse?.name ?? 'Unknown User';
  }

  String? getDisplayImage() {
    if (isGroup) {
      return groupImage;
    }
    return userResponse?.profileImage;
  }
}

class ConversationInputModel {
  final String? conversationId;
  final bool isGroup;
  final List<String> members;
  final String? userId;
  final String? groupName;
  final String? groupImage;

  ConversationInputModel({
    this.conversationId,
    required this.isGroup,
    this.members = const [],
    this.userId,
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
