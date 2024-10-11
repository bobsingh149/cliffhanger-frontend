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

class PostUserBook extends Book {
  final String userId;
  final String caption;
  final PostCategory category;
  Uint8List? postImage;

  PostUserBook({
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

  factory PostUserBook.fromJson(Map<String, dynamic> json) {
    return PostUserBook(
      title: json['title'],
      score: json['score'],
      authors: List<String>.from(json['authors'] ?? []),
      coverImages: List<String>.from(json['coverImages'] ?? []),
      subjects: List<String>.from(json['subjects'] ?? []),
      userId: json['userId'],
      caption: json['caption'],
      category: PostCategory.values.byName(json['category']),
      postImage: json['imageByUser'],
    );
  }

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

class UserBook extends Book {
  final String id;
  final String userId;
  final String caption;
  final PostCategory category;
  final String? postImage;
  final DateTime createdAt;

  UserBook({
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
  });

  /// Create a UserBook object from a JSON map.
  factory UserBook.fromJson(Map<String, dynamic> json) {
    json = json["data"];
  

    return UserBook(
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
        createdAt: DateTime.parse(json['createdAt']));
  }

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
      'createdAt': createdAt.toString()
    };
  }
}
