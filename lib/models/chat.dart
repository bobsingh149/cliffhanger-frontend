class ChatModel {
  String from;  // Single user who sent the message
  String message;
  bool isRead;
  bool isGroup;
  DateTime timestamp;
  bool isImage;
  String? imageUrl;

  // Constructor
  ChatModel({
    required this.from,
    required this.message,
    this.isRead = false,
    this.isGroup = false,
    required this.timestamp,
    required this.isImage,
    this.imageUrl,
  });

  // Convert a ChatModel instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'message': message,
      'isRead': isRead,
      'isGroup': isGroup,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isImage': isImage,
      'imageUrl': imageUrl,
    };
  }

  // Convert JSON to a ChatModel instance
  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      from: json['from'],
      message: json['message'],
      isRead: json['isRead'],
      isGroup: json['isGroup'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      isImage: json['isImage'] ?? false,
      imageUrl: json['imageUrl'],
    );
  }
}
