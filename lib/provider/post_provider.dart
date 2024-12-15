import 'package:barter_frontend/models/post.dart';
import 'package:barter_frontend/models/post_category.dart';
import 'package:barter_frontend/services/auth_services.dart';
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


  Future<List<PostModel>> getFeedPosts({
    required FilterType filterType,
    required String userId,
    required int page,
    required int size,
    String? searchQuery,
    String? city,
  }) async {
    try {
      
  
    List<PostModel> newPosts;
      switch (filterType) {
        case FilterType.all:
          newPosts = await _postService.getAllPosts(
            userId,
            page: page,
            size: size,
            filterType: filterType,
          );
          break;
          
        case FilterType.userPosts:
          newPosts = await _postService.getPostsByUser(userId);
          break;
          
        case FilterType.barter:
          if (city == null) throw Exception('City is required for barter filter');
          newPosts = await _postService.getBarterPosts(
            userId,
            city: city,
            page: page,
            size: size,
          );
          break;
          
        case FilterType.search:
          if (searchQuery == null) throw Exception('Search query is required');
          newPosts = await _postService.searchPosts(
            userId,
            searchQuery: searchQuery,
            page: page,
            size: size,
          );
          break;
        default:
          throw Exception('filter type not currently supported');
      }

      return newPosts;
      
    } catch (err) {
      _logger.e(err);
      rethrow;
    }
  }

  Future<List<Comment>> getPostComments(String postId) async {
    try {
      final comments = await _postService.getComments(postId);
      return comments;
    } catch (err) {
      _logger.e(err);
      rethrow;
    }
  }


  Future<void>  likePost(String postId) async {
    try {
      final userId = AuthService.getInstance.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');
      await _postService.likePost(postId, userId);
      notifyListeners(); // Notify listeners to rebuild UI if needed
    } catch (err) {
      _logger.e(err);
      rethrow;
    }
  }

  
   Future<void> addComment(String postId, String comment) async {
    try {
      final userId = AuthService.getInstance.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      await _postService.postComment(postId, userId, comment);
      notifyListeners();
    } catch (err) {
      _logger.e(err);
      rethrow;
    }
  }

  Future<void> likeComment(String postId, String commentId) async {
    try {
      await _postService.likeComment(postId, commentId);
      notifyListeners();
    } catch (err) {
      _logger.e(err);
      rethrow;
    }
  }
  
}
