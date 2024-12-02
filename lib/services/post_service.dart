import 'dart:convert';
import 'dart:io';

import 'package:barter_frontend/constants/api_constants.dart';
import 'package:barter_frontend/models/post.dart';
import 'package:barter_frontend/utils/app_logger.dart';
import 'package:barter_frontend/utils/http_client.dart';
import 'package:barter_frontend/utils/service_utils.dart';
import 'package:http/http.dart' as http;

class PostService {
  final http.Client client;
  static PostService? _instance;

  PostService({http.Client? client})
      : client = client ?? AppHttpClient.instance.client;

  static PostService get getInstance {
    _instance ??= PostService();

    return _instance!;
  }

  Future<List<PostModel>> getPostsByUser(String userId) async {
    final response = await client
        .get(Uri.parse("${ApiRoutePaths.bookUrl}/getProductByUserId/$userId"));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = ServiceUtils.parseResponse(response);
      return data.map((json) => PostModel.fromJson(json)).toList();
    }
    throw Exception(ServiceUtils.parseErrorMessage(response));
  }

  Future<List<PostModel>> getAllPosts(String userId, {
    required int page,
    required int size,
    required FilterType filterType,
  }) async {
    final response = await client.get(
      Uri.parse("${ApiRoutePaths.getAllProducts}/$userId").replace(
        queryParameters: {
          'page': page.toString(),
          'size': size.toString(),
        },
      ),
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = ServiceUtils.parseResponse(response);
      return data.map((json) => PostModel.fromJson(json)).toList();
    }
    throw Exception(ServiceUtils.parseErrorMessage(response));
  }

  Future<List<PostModel>> getBarterPosts(String userId, {
    required String city,   
    required int page,
    required int size,
  }) async {
    final response = await client.get(
      Uri.parse(ApiRoutePaths.getByBarterFilter).replace(
        queryParameters: {
          'city': city,
          'userId': userId,
          'page': page.toString(),
          'size': size.toString(),
        },
      ),
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = ServiceUtils.parseResponse(response);
      return data.map((json) => PostModel.fromJson(json)).toList();
    }
    throw Exception(ServiceUtils.parseErrorMessage(response));
  }

  Future<List<PostModel>> searchPosts(String userId, {
    required String searchQuery,
    required int page,
    required int size,
  }) async {
    final response = await client.get(
      Uri.parse(ApiRoutePaths.getPostsBySearch).replace(
        queryParameters: {
          'q': searchQuery,
          'userId': userId,
          'page': page.toString(),
          'size': size.toString(),
        },
      ),
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = ServiceUtils.parseResponse(response);
      return data.map((json) => PostModel.fromJson(json)).toList();
    }
    throw Exception(ServiceUtils.parseErrorMessage(response));
  }

  Future<PostModel> getPostById(String postId) async {
    final response = await client.get(
      Uri.parse("${ApiRoutePaths.bookUrl}/getProductById/$postId"),
    );
    
    if (response.statusCode == 200) {
      return PostModel.fromJson(ServiceUtils.parseResponse(response));
    }
    throw Exception(ServiceUtils.parseErrorMessage(response));
  }

  Future<void> deletePost(String postId) async {
    final response = await client.delete(
      Uri.parse("${ApiRoutePaths.bookUrl}/deleteProductById/$postId"),
    );
    
    if (response.statusCode != 200) {
      throw Exception(ServiceUtils.parseErrorMessage(response));
    }
  }

  Future<void> savePost(SavePost post, {File? imageFile}) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("${ApiRoutePaths.bookUrl}/saveProduct"),
    );

    request.headers['Content-Type'] = ApiHeaders.multipartFormData;

    request.fields['data'] = jsonEncode(post.toJson());
    
    if (imageFile != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          ApiRequestFields.file,
          await imageFile.readAsBytes(),
          filename: imageFile.path.split('/').last,
        ),
      );
    }

    final streamedResponse = await client.send(request);
    final response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode == 201) {
      return;
    }
    throw Exception(ServiceUtils.parseErrorMessage(response));
  }

  Future<void> postComment(String postId, String userId, String comment) async {
    final response = await client.post(
      Uri.parse("${ApiRoutePaths.bookUrl}/postComment"),
      body: jsonEncode({
        'productId': postId,
        'userId': userId,
        'text': comment,
      }),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode != 201) {
      throw Exception(ServiceUtils.parseErrorMessage(response));
    }
  }

  Future<void> likePost(String postId, String userId) async {
    final response = await client.post(
      Uri.parse("${ApiRoutePaths.bookUrl}/postLike"),
      body: jsonEncode({
        'productId': postId,
        'userId': userId,
      }),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode != 201) {
      throw Exception(ServiceUtils.parseErrorMessage(response));
    }
  }

  Future<void> likeComment(String postId, String commentId) async {
    final response = await client.post(
      Uri.parse("${ApiRoutePaths.bookUrl}/likeComment").replace(
        queryParameters: {
          'productId': postId,
          'commentId': commentId,
        },
      ),
    );
    
    if (response.statusCode != 200) {
      throw Exception(ServiceUtils.parseErrorMessage(response));
    }
  }

  Future<List<Comment>> getComments(String postId) async {
    final response = await client.get(
      Uri.parse('${ApiRoutePaths.bookUrl}${ApiRoutePaths.getComments}/$postId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> commentsJson =ServiceUtils.parseResponse(response);
      return commentsJson.map((json) => Comment.fromJson(json)).toList();
    } else {
      throw Exception(ServiceUtils.parseErrorMessage(response));
    }
  }
}
