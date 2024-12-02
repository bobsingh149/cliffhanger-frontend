import 'dart:typed_data';
import 'package:barter_frontend/models/book_category.dart';

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
  final String userId;
  final String caption;
  final PostCategory category;
  final String? postImage;
  final DateTime createdAt;
  int likesCount;
  List<Comment> comments;
  final String? description; // New optional description field

  PostModel({
    required this.id,
    required super.title,
    required super.score,
    super.authors,
    super.coverImages,
    super.subjects,
    required this.userId,
    required this.caption,
    required this.category,
    this.postImage,
    required this.createdAt,
    required this.likesCount,
    required this.comments,
    this.description, // Added to the constructor
  });

  /// Create a UserPost object from a JSON map.
  factory PostModel.fromJson(Map<String, dynamic> json) {

    return PostModel(
        id: json['id'] as String,
        title: json['title'] as String,
        score: json['score'] as int,
        authors: (json['authors'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        coverImages: (json['coverImages'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        subjects: (json['subjects'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        userId: json['userId'] as String,
        caption: json['caption'] as String,
        category: stringToPostCategory(
            json['category'])!, // Convert category from string
        postImage: json['postImage'],
        createdAt: DateTime.parse(json['createdAt']),
        likesCount: 500, // json['likes'] as int,
        comments: (json['comments'] as List<dynamic>)
            .map((e) => Comment.fromJson(e as Map<String, dynamic>))
            .toList(),
        description: json['description'] as String?); // Added to fromJson
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
      'userId': userId,
      'caption': caption,
      'category':
          category.name, // Assuming PostCategory can be converted to a string
      'postImage': postImage,
      'createdAt': createdAt.toString(),
      'likesCount': likesCount,
      'comments': comments.map((comment) => comment.toJson()).toList(),
      'description': description, // Added to toJson
    };
  }
}

class Comment {
  final String text;
  final String userId;
  final DateTime timestamp;
  final int likeCount;
  final String username;

  Comment({
    required this.text,
    required this.userId,
    required this.timestamp,
    required this.likeCount,
    required this.username,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      text: json['text'] as String,
      userId: json['userId'] as String,
      timestamp: DateTime.parse(json['timestamp']),
      likeCount: json['likeCount'] as int,
      username: json['username'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'likeCount': likeCount,
      'username': username,
    };
  }
}


