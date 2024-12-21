class SaveConversationInput {
  final String? conversationId;
  final bool isGroup;
  final List<String> members;
  final String? userId;
  final String? groupName;
  final String? groupImage;

  SaveConversationInput({
    this.conversationId,
    required this.isGroup,
    this.members = const [],
    this.userId,
    this.groupName,
    this.groupImage,
  });

  Map<String, dynamic> toJson() => {
    'conversationId': conversationId,
    'isGroup': isGroup,
    'members': members,
    'userId': userId,
    'groupName': groupName,
    'groupImage': groupImage,
  };
} 