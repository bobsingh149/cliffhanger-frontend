class SaveConversationInput {
  final String? conversationId;
  final bool isGroup;
  final List<String> users;
  final String userId;
  final String? groupName;
  final String? groupImage;

  SaveConversationInput({
    this.conversationId,
    required this.isGroup,
    required this.users,
    required this.userId,
    this.groupName,
    this.groupImage,
  });

  Map<String, dynamic> toJson() => {
    'conversationId': conversationId,
    'isGroup': isGroup,
    'users': users,
    'userId': userId,
    'groupName': groupName,
    'groupImage': groupImage,
  };
} 