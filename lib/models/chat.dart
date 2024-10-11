class ChatModel {
  String from;  // Single user who sent the message
  List<String> to;  // List of users (for group or multiple recipients)
  String message;
  bool isRead;
  bool isGroup;
  DateTime timestamp;

  // Constructor
  ChatModel({
    required this.from,
    required this.to,
    required this.message,
    this.isRead = false,
    this.isGroup = false,
    required this.timestamp,
  });

  // Convert a ChatModel instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'to': to,
      'message': message,
      'isRead': isRead,
      'isGroup': isGroup,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  // Convert JSON to a ChatModel instance
  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      from: json['from'],
      to: List<String>.from(json['to']), // Convert to list of strings
      message: json['message'],
      isRead: json['isRead'],
      isGroup: json['isGroup'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
    );
  }
}
