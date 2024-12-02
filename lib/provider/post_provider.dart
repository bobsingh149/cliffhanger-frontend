import 'package:barter_frontend/models/post.dart';
import 'package:barter_frontend/models/book_category.dart';
import 'package:barter_frontend/services/post_service.dart';
import 'package:barter_frontend/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:barter_frontend/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PostProvider with ChangeNotifier {
  final AppLogger _logger = AppLogger.instance;
  bool isLoading = false;
  final PostService _postService;

  PostProvider({PostService? postService})
      : _postService = postService ?? PostService.getInstance;

  Map<PostCategory, List<PostModel>>? _proflePosts;

  Map<PostCategory, List<PostModel>>? get profilePosts {
    return _proflePosts;
  }

  Future<Map<PostCategory, List<PostModel>>?> getUserPosts(String userId) async {
    if (_proflePosts != null) {
      return _proflePosts;
    }

    try {
      _proflePosts = {};
      for (var category in postCategoryList) {
        _proflePosts![category] = [];
      }

      final posts = await _postService.getPostsByUser(userId);
      
      for (var post in posts) {
        _proflePosts![post.category]!.add(post);
      }

      return _proflePosts;
    } catch (err) {
      _logger.e(err);
      rethrow;
    }
  }

  List<PostModel>? _feedPosts;

  List<PostModel>? get feedPosts => _feedPosts;

  Future<List<PostModel>> getFeedPosts({
    required FilterType filterType,
    required String userId,
    int page = 0, 
    int size = 10,
    String? searchQuery,
    String? city,
  }) async {
    try {
      switch (filterType) {
        case FilterType.all:
          _feedPosts = await _postService.getAllPosts(
            userId,
            page: page,
            size: size,
            filterType: filterType,
          );
          break;
          
        case FilterType.userPosts:
          _feedPosts = await _postService.getPostsByUser(userId);
          break;
          
        case FilterType.barter:
          if (city == null) throw Exception('City is required for barter filter');
          _feedPosts = await _postService.getBarterPosts(
            userId,
            city: city,
            page: page,
            size: size,
          );
          break;
          
        case FilterType.search:
          if (searchQuery == null) throw Exception('Search query is required');
          _feedPosts = await _postService.searchPosts(
            userId,
            searchQuery: searchQuery,
            page: page,
            size: size,
          );
          break;
        default:
          throw Exception('filter type not currently supported');
      }

      return _feedPosts!;
    } catch (err) {
      _logger.e(err);
      rethrow;
    }
  }

  Future<List<PostModel>> getMockFeedPosts() async {
    return [
      PostModel(
        id: "id1",
        title: "The Great Gatsby",
        score: 4,
        userId: "user1",
        caption: "Classic American novel exploring themes of wealth, love, and the American Dream in the Roaring Twenties. A must-read masterpiece by F. Scott Fitzgerald.",
        likesCount: 10,
        coverImages: [
          '',
          '',
          'https://res.cloudinary.com/dllr1e6gn/image/upload/v1/profile_images/aemio6hooqxp1eiqzpev'
        ],
        comments: [
          Comment(userId: "user2", username: "Jane Smith", text: "Great book!", timestamp: DateTime.now(), likeCount: 0),
          Comment(userId: "user3", username: "Alex Johnson", text: "Love it", timestamp: DateTime.now(), likeCount: 0),
        ],
        category: PostCategory.currentlyReading,
        createdAt: DateTime.now(),
        postImage: null,
      ),
      // ... rest of the mock posts ...
    ];
  }

  Future<Map<PostCategory, List<PostModel>>?> getUserMockPosts(String userId) async {
    try {
      // Initialize empty lists for each category
      _proflePosts = {};
      for (var category in postCategoryList) {
        _proflePosts![category] = [];
      }

      // Create mock posts
      final mockPosts = [
        // Currently Reading Books
        PostModel(
          id: "cr1",
          title: "The Midnight Library",
          score: 4,
          userId: userId,
          caption: "A fascinating exploration of parallel lives and second chances.",
          likesCount: 180,
          coverImages: ['https://picsum.photos/201'],
          comments: [Comment(userId: "user2", username: "Jane Smith", text: "Life-changing read!", timestamp: DateTime.now(), likeCount: 0)],
          category: PostCategory.currentlyReading,
          createdAt: DateTime.now(),
          postImage: null,
        ),
        PostModel(
          id: "cr2",
          title: "Project Hail Mary",
          score: 5,
          userId: userId,
          caption: "Andy Weir's latest sci-fi masterpiece.",
          likesCount: 165,
          coverImages: ['https://picsum.photos/202'],
            comments: [Comment(userId: "user3", username: "Alex", text: "Amazing science fiction!", timestamp: DateTime.now(), likeCount: 0)],
          category: PostCategory.currentlyReading,
          createdAt: DateTime.now(),
          postImage: null,
        ),
        PostModel(
          id: "cr3",
          title: "The Seven Husbands of Evelyn Hugo",
          score: 4,
          userId: userId,
          caption: "A gripping tale of old Hollywood glamour and hidden truths.",
          likesCount: 195,
          coverImages: ['https://picsum.photos/203'],
          comments: [Comment(userId: "user4", username: "Maria", text: "Couldn't put it down!", timestamp: DateTime.now(), likeCount: 0)],
          category: PostCategory.currentlyReading,
          createdAt: DateTime.now(),
          postImage: null,
        ),
        PostModel(
          id: "cr4",
          title: "Tomorrow, and Tomorrow, and Tomorrow",
          score: 5,
          userId: userId,
          caption: "A beautiful story about friendship, love, and video game development.",
          likesCount: 142,
          coverImages: ['https://picsum.photos/204'],
          comments: [Comment(userId: "user5", username: "David", text: "A masterpiece!", timestamp: DateTime.now(), likeCount: 0)],
          category: PostCategory.currentlyReading,
          createdAt: DateTime.now(),
          postImage: null,
        ),
        PostModel(
          id: "cr5",
          title: "Lessons in Chemistry",
          score: 4,
          userId: userId,
          caption: "A brilliant debut about a female chemist in the 1960s breaking barriers.",
          likesCount: 175,
          coverImages: ['https://picsum.photos/205'],
          comments: [Comment(userId: "user6", username: "Rachel", text: "Inspiring read!", timestamp: DateTime.now(), likeCount: 0  )],
          category: PostCategory.currentlyReading,
          createdAt: DateTime.now(),
          postImage: null,
        ),

        // Barter Books
        PostModel(
          id: "b1",
          title: "Dune",
          score: 5,
          userId: userId,
          caption: "Classic sci-fi in perfect condition. Looking to trade for fantasy novels.",
          likesCount: 210,
          coverImages: ['https://picsum.photos/206'],
          comments: [Comment(userId: "user4", username: "Sarah", text: "Interested in trading!", timestamp: DateTime.now(), likeCount: 0  )],
          category: PostCategory.barter,
          createdAt: DateTime.now(),
          postImage: null,
        ),

        // Favourite Books
        PostModel(
          id: "f1",
          title: "Pride and Prejudice",
          score: 5,
          userId: userId,
          caption: "A timeless classic that never fails to delight.",
          likesCount: 250,
          coverImages: ['https://picsum.photos/207'],
          comments: [Comment(userId: "user5", username: "Emma", text: "My favorite too!", timestamp: DateTime.now(), likeCount: 0   )],
          category: PostCategory.favourite,
          createdAt: DateTime.now(),
          postImage: null,
        ),
      ];

      // Add all books for each category
      for (var category in postCategoryList) {
        _proflePosts![category] = mockPosts.where((post) => post.category == category).toList();
      }

      _logger.i("Mock posts loaded successfully");
      return _proflePosts;
    } catch (err) {
      _logger.e(err);
      return null;
    }
  }
  
}
