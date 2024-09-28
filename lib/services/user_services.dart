// services/user_service.dart

import 'dart:convert';
import 'package:barter_frontend/constants/api_constants.dart';
import 'package:barter_frontend/models/user_info.dart';
import 'package:http/http.dart' as http;

class UserService {
  final http.Client client;

  UserService({http.Client? client})
      : client = client ?? http.Client(); // Allows for dependency injection

  Future<UserInfo?> fetchUser(String userId) async {
    final response =
        await client.get(Uri.parse('${ApiRoutePaths.userUrl}/$userId'));

    if (response.statusCode == 200) {
      return UserInfo.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<void> saveUserInfo(UserInfo user) async {
    final response =
        await client.post(Uri.parse('${ApiRoutePaths.baseUrl}/saveUser'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(user.toJson()));

    if (response.statusCode != 201) {
      throw Exception(jsonDecode(response.body)["message"]);
    }
  }

  // Close the client if needed (e.g., during disposal)
  void dispose() {
    client.close();
  }
}
