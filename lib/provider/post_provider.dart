import 'package:barter_frontend/models/post.dart';
import 'package:barter_frontend/models/post_category.dart';
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

  Future<List<Comment>> getPostComments(String postId) async {
    try {
      final comments = await _postService.getComments(postId);
      return comments;
    } catch (err) {
      _logger.e(err);
      rethrow;
    }
  }
}
