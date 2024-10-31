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

  Future<Map<PostCategory, List<UserBook>>?> getUserPosts(String userId) async {
    try {
      List<UserBook> posts = await _postService.getPostsByUser(userId);
      _logger.i(posts);
      for (var category in postCategoryList) {
        _proflePosts![category] = [];
      }
      for (var post in posts) {
        _proflePosts![post.category]!.add(post);
      }

      _logger.i("success");
      return _proflePosts;

    } catch (err) {
      _logger.e(err);
    }
  }

  List<UserBook>? _feedPosts;

  List<UserBook>? get feedPosts => _feedPosts;

  Future<List<UserBook>> getFeedPosts() async {
    try {
      // TODO: Replace with actual API call
      _feedPosts = [
        UserBook(
          id: "id1",
          title: "The Great Gatsby",
          score: 4,
          userId: "user1",
          username: "John Doe",
          caption: "Classic American novel",
          likesCount: 10,
          coverImages: [
            '',
            '',
            'https://res.cloudinary.com/dllr1e6gn/image/upload/v1/profile_images/aemio6hooqxp1eiqzpev'
          ],
          comments: [
            Comment(
                userId: "user2", username: "Jane Smith", text: "Great book!"),
            Comment(userId: "user3", username: "Alex Johnson", text: "Love it"),
          ],
          category: PostCategory.barter,
          createdAt: DateTime.now(),
          postImage: null,
        ),
        // ... other mock posts ...
      ];
      return _feedPosts!;
    } catch (err) {
      _logger.e(err);
      throw err;
    }
  }
}
