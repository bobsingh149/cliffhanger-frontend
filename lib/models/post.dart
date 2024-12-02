import 'dart:typed_data';
import 'package:barter_frontend/models/post_category.dart';
import 'package:barter_frontend/models/user.dart';

class Book {
  final String title;
  final int score;
  final List<String>? authors;
  final List<String>? coverImages;
  final List<String>? subjects;

  Book({
    required this.title,
    required this.score,
    this.authors,
    this.coverImages,
    this.subjects,
  });

  // Factory method to create a Book instance from JSON
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'],
      score: json['score'] as int,
      authors:
          json['authors'] != null ? List<String>.from(json['authors']) : null,
      coverImages: json['coverImages'] != null
          ? List<String>.from(json['coverImages'])
          : null,
      subjects:
          json['subjects'] != null ? List<String>.from(json['subjects']) : null,
    );
  }

  // Method to convert Book instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'score': score,
      'authors': authors ?? [],
      'coverImages': coverImages ?? [],
      'subjects': subjects ?? [],
    };
  }
}

class SavePost extends Book {
  final String userId;
  final String? caption;
  final PostCategory category;
  Uint8List? postImage;

  SavePost({
    required super.title,
    required super.score,
    super.authors,
    super.coverImages,
    super.subjects,
    required this.userId,
    required this.caption,
    required this.category,
    this.postImage,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'score': score,
      'authors': authors,
      'coverImages': coverImages,
      'subjects': subjects,
      'userId': userId,
      'caption': caption,
      'category': category.name,
    };
  }
}

enum FilterType{
  all,
  barter,
  search,
  userPosts,
  connectionsPosts,
}

class PostModel extends Book {
  final String id;
  final UserModel userInfo;
  final String caption;
  final PostCategory category;
  final String? postImage;
  final DateTime createdAt;
  final List<String> likes;
  final int likesCount;
  final int commentCount;
  final String? description;

  PostModel({
    required this.id,
    required super.title,
    required super.score,
    super.authors,
    super.coverImages,
    super.subjects,
    required this.userInfo,
    required this.caption,
    required this.category,
    this.postImage,
    required this.createdAt,
    required this.likes,
    required this.likesCount,
    required this.commentCount,
    this.description,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      title: json['title'] as String,
      score: json['score'] as int,
      authors: (json['authors'] as List<dynamic>?)?.map((e) => e as String).toList(),
      coverImages: (json['coverImages'] as List<dynamic>?)?.map((e) => e as String).toList(),
      subjects: (json['subjects'] as List<dynamic>?)?.map((e) => e as String).toList(),
      userInfo: UserModel.fromJson(json['userResponse']),
      caption: json['caption'] as String,
      category: stringToPostCategory(json['category'])!,
      postImage: json['postImage'],
      createdAt: DateTime.parse(json['createdAt']),
      likes: (json['likes'] as List<dynamic>).map((e) => e as String).toList(),
      likesCount: json['likeCount'] as int,
      commentCount: json['commentCount'] as int,
      description: json['description'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'score': score,
      'authors': authors,
      'coverImages': coverImages,
      'subjects': subjects,
      'userResponse': userInfo.toJson(),
      'caption': caption,
      'category': category.name,
      'postImage': postImage,
      'createdAt': createdAt.toString(),
      'likes': likes,
      'likeCount': likesCount,
      'commentCount': commentCount,
      'description': description,
    };
  }
}

class Comment {
  final String id;
  final String text;
  final UserModel userInfo;
  final DateTime timestamp;
  final int likeCount;

  Comment({
    required this.id,
    required this.text,
    required this.userInfo,
    required this.timestamp,
    required this.likeCount,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      text: json['text'] as String,
      userInfo: UserModel.fromJson(json['userResponse']),
      timestamp: DateTime.parse(json['timestamp']),
      likeCount: json['likeCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'userResponse': userInfo.toJson(),
      'timestamp': timestamp.toIso8601String(),
      'likeCount': likeCount,
    };
  }
}


