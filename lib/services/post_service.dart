import 'dart:convert';

import 'package:barter_frontend/constants/api_constants.dart';
import 'package:barter_frontend/models/book.dart';
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

  Future<List<UserBook>> getPostsByUser(String userId) async {
    final response = await client
        .get(Uri.parse("${ApiRoutePaths.bookUrl}/getProductByUserId/$userId"));
    print("status code:-  ${response.statusCode}");
    if (response.statusCode == 200) {
      List<dynamic> userBooks = jsonDecode(response.body);
      return userBooks.map((book) => UserBook.fromJson(book)).toList();
    } else {
      throw Exception(ServiceUtils.parseErrorMessage(response));
    }
  }
}
