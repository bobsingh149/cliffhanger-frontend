import 'package:barter_frontend/models/user.dart';
import 'package:logger/logger.dart';

final _logger = Logger();

class UserSetupModel {
  final String id;
  final String name;
  final int? age;
  final String? bio;
  final String? city;
  final String? profileImage;
  final List<String> connections;
  final List<BookBuddy> bookBuddies;
  final List<ConversationModel> conversations;
  final List<RequestModel> requests;

  UserSetupModel({
    required this.id,
    required this.name,
    this.age,
    this.bio,
    this.city,
    this.profileImage,
    this.connections = const [],
    this.bookBuddies = const [],
    this.conversations = const [],
    this.requests = const [],
  });

  factory UserSetupModel.fromJson(Map<String, dynamic> json) {
    _logger.d('Parsing user setup: $json');
    return UserSetupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int?,
      bio: json['bio'] as String?,
      city: json['city'] as String?,
      profileImage: json['profileImage'] as String?,
      connections: List<String>.from(json['connections'] ?? []),
      bookBuddies: (json['bookBuddies'] as List?)
              ?.map((e) => BookBuddy.fromJson(e))
              .toList() ??
          [],
      conversations: (json['conversations'] as List?)
              ?.map((e) => ConversationModel.fromJson(e))
              .toList() ??
          [],
      requests: (json['requests'] as List?)
              ?.map((e) => RequestModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'age': age,
        'bio': bio,
        'city': city,
        'profileImage': profileImage,
        'connections': connections,
        'bookBuddies': bookBuddies.map((e) => e.toJson()).toList(),
        'conversations': conversations.map((e) => e.toJson()).toList(),
        'requests': requests.map((e) => e.toJson()).toList(),
      };
}

class ConversationModel {
  final String conversationId;
  final bool isGroup;
  final List<UserModel> members;
  final UserModel? userResponse;
  final String? groupName;
  final String? groupImage;

  ConversationModel({
    required this.conversationId,
    required this.isGroup,
    this.members = const [],
    this.userResponse,
    this.groupName,
    this.groupImage,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      conversationId: json['conversationId'] as String,
      isGroup: json['group'] as bool,
      members: (json['members'] as List?)
              ?.map((e) => UserModel.fromJson(e))
              .toList() ??
          [],
      userResponse: json['userResponse'] != null
          ? UserModel.fromJson(json['userResponse'])
          : null,
      groupName: json['groupName'] as String?,
      groupImage: json['groupImage'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'conversationId': conversationId,
        'group': isGroup,
        'members': members.map((e) => e.toJson()).toList(),
        'userResponse': userResponse?.toJson(),
        'groupName': groupName,
        'groupImage': groupImage,
      };
}

class RequestModel {
  final UserModel userResponse;
  final DateTime timestamp;

  RequestModel({
    required this.userResponse,
    required this.timestamp,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      userResponse: UserModel.fromJson(json['userResponse']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() => {
        'userResponse': userResponse.toJson(),
        'timestamp': timestamp.toIso8601String(),
      };
}
