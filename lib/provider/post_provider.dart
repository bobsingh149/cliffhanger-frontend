import 'package:barter_frontend/models/book.dart';
import 'package:barter_frontend/models/book_category.dart';
import 'package:barter_frontend/services/post_service.dart';
import 'package:barter_frontend/utils/app_logger.dart';
import 'package:flutter/material.dart';

class PostProvider with ChangeNotifier {
  final AppLogger _logger = AppLogger.instance;
  bool isLoading = false;
  final PostService _postService;

  PostProvider({PostService? postService})
      : _postService = postService ?? PostService.getInstance;

  Map<PostCategory, List<UserBook>>? _proflePosts = {};

  Map<PostCategory, List<UserBook>>? get profilePosts {
    return _proflePosts;
  }

  Future<void> setUserPosts(String userId) async {
    isLoading = true;
    // notifyListeners();

    try {
      List<UserBook> posts = await _postService.getPostsByUser(userId);
      _logger.i(posts);
      for (var category in postCategoryList) {
        _proflePosts![category] = [];
      }

      _logger.d("working");
      for (var post in posts) {
        _proflePosts![post.category]!.add(post);
      }
      _logger.i("success");
    } catch (err) {
      _logger.e(err);
    } finally {
      isLoading = false;
      // notifyListeners();
    }
  }
}
