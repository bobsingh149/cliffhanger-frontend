import 'dart:convert';
import 'dart:typed_data';
import 'package:barter_frontend/constants/api_constants.dart';
import 'package:barter_frontend/models/contact.dart';
import 'package:barter_frontend/models/save_conversation_input.dart';
import 'package:barter_frontend/models/save_request_input.dart';
import 'package:barter_frontend/models/user.dart';
import 'package:barter_frontend/models/user_setup.dart';
import 'package:barter_frontend/services/auth_services.dart';
import 'package:barter_frontend/utils/app_logger.dart';
import 'package:barter_frontend/utils/http_client.dart';
import 'package:barter_frontend/utils/service_utils.dart';
import 'package:http/http.dart' as http;

class UserService {
  final http.Client client;

  static UserService? _instance;

  static UserService get getInstance {
    _instance ??= UserService();

    return _instance!;
  }

  UserService({http.Client? client})
      : client = client ??
            AppHttpClient
                .instance.client; // Allows for the dependency injection

  Future<UserModel?> fetchUser(String userId) async {
    final response =
        await client.get(Uri.parse('${ApiRoutePaths.getUser}/$userId'));

    if (response.statusCode == 200) {
      return UserModel.fromJson(ServiceUtils.parseResponse(response));
    } else if (response.statusCode >= 400) {
      throw Exception(ServiceUtils.parseErrorMessage(response));
    } else {
      throw Exception(ServiceUtils.parseErrorMessage(response));
    }
  }

  Future<void> saveUser(UserModel user, Uint8List? profileImage) async {
    AppLogger.instance.e('Saving user: $user');

    var request = http.MultipartRequest(
        'POST', Uri.parse(ApiRoutePaths.saveUser));

    request.headers['Content-Type'] = ApiHeaders.multipartFormData;

    // Attach the JSON data as a field
    request.fields['data'] = jsonEncode(user.toJson());

    // Attach the image file if it exists
    if (profileImage != null) {
      final imageData = profileImage;
      request.files.add(
        http.MultipartFile.fromBytes(ApiRequestFields.file, imageData,
            filename: ApiFileNames.profileImage),
      );
    }

    // Send the request and await the response
    final response = await request.send();
    final responseBody = await http.Response.fromStream(response);

    AppLogger.instance.i('Response: $responseBody');

    if (response.statusCode >= 400) {
      throw Exception(ServiceUtils.parseErrorMessage(responseBody));
    }
  }

  Future<GetBookBuddy> getBookBuddy(String userId) async {
    final response = await client.get(
      Uri.parse('${ApiRoutePaths.getBookBuddy}?id=$userId'),
    );

       if (response.statusCode >= 400) {
        throw Exception(ServiceUtils.parseErrorMessage(response));
       }

      return GetBookBuddy.fromJson(ServiceUtils.parseResponse(response)[0]);

      
  }

  Future<void> updateUser(UserModel user, Uint8List? profileImage) async {
    AppLogger.instance.i('Updating user: $user');

    var request = http.MultipartRequest(
        'PUT', Uri.parse(ApiRoutePaths.updateUser));

    request.headers['Content-Type'] = ApiHeaders.multipartFormData;

    // Attach the JSON data as a field
    request.fields['data'] = jsonEncode(user.toJson());

    // Attach the image file if it exists
    if (profileImage != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          ApiRequestFields.file,
          profileImage,
          filename: ApiFileNames.profileImage,
        ),
      );
    }

    // Send the request and await the response
    final response = await request.send();
    final responseBody = await http.Response.fromStream(response);

    AppLogger.instance.i('Response: $responseBody');

    if (response.statusCode >= 400) {
      throw Exception(ServiceUtils.parseErrorMessage(responseBody));
    }
  }

  Future<void> saveConnection(SaveConversationInput input) async {
    final userId = AuthService.getInstance.currentUser!.uid;
    final response = await client.post(
      Uri.parse('${ApiRoutePaths.saveConnection}/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(input.toJson()),
    );

    if (response.statusCode >= 400) {
      throw Exception(ServiceUtils.parseErrorMessage(response));
    }
  }

  Future<UserSetupModel> getUserSetup(String userId) async {
    final response = await client.get(
      Uri.parse('${ApiRoutePaths.getUserSetup}/$userId'),
    );

    if (response.statusCode == 200) {
      return UserSetupModel.fromJson(ServiceUtils.parseResponse(response));
    } else if (response.statusCode >= 400) {
      throw Exception(ServiceUtils.parseErrorMessage(response));
    } else {
      throw Exception(ServiceUtils.parseErrorMessage(response));
    }
  }

  Future<List<UserModel>> getCommonUsers(String userId,
      {required int page, required int size}) async {
    final response = await client.get(
      Uri.parse('${ApiRoutePaths.getCommonUsers}/$userId?page=$page&size=$size'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = ServiceUtils.parseResponse(response);
      return data.map((json) => UserModel.fromJson(json)).toList();
    } else if (response.statusCode >= 400) {
      throw Exception(ServiceUtils.parseErrorMessage(response));
    } else {
      throw Exception(ServiceUtils.parseErrorMessage(response));
    }
  }

  Future<void> saveRequest(SaveRequestInput input) async {
    final response = await client.post(
      Uri.parse(ApiRoutePaths.saveRequest),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(input.toJson()),
    );

    if (response.statusCode >= 400) {
      throw Exception(ServiceUtils.parseErrorMessage(response));
    }
  }

  Future<void> removeRequest(SaveRequestInput input) async {
    final response = await client.delete(
      Uri.parse(ApiRoutePaths.removeRequest),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(input.toJson()),
    );

    if (response.statusCode >= 400) {
      throw Exception(ServiceUtils.parseErrorMessage(response));
    }
  }

  Future<void> deleteUser(String userId) async {
    final response = await client.delete(
      Uri.parse('${ApiRoutePaths.deleteUser}/$userId'),
    );

    if (response.statusCode >= 400) {
      throw Exception(ServiceUtils.parseErrorMessage(response));
    }
  }

  Future<void> createGroup({
    required String name,
    required List<String> memberIds,
    String? description,
    Uint8List? groupImage,
  }) async {
    final userId = AuthService.getInstance.currentUser!.uid;

    memberIds.add(userId);

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiRoutePaths.saveGroup}/$userId'),
    );

    // Create ConversationInputModel
    final input = ConversationInputModel(
      isGroup: true,
      members: memberIds,
      userId:null,
      groupName: name,
    );

    request.headers['Content-Type'] = ApiHeaders.multipartFormData;
    request.fields['data'] = jsonEncode(input.toJson());

    // Add group image if provided
    if (groupImage != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          ApiRequestFields.file,
          groupImage,
          filename: ApiFileNames.groupImage,
        ),
      );
    }

    final response = await request.send();
    final responseBody = await http.Response.fromStream(response);

    if (response.statusCode >= 400) {
      throw Exception(ServiceUtils.parseErrorMessage(responseBody));
    }
  }

  // Close the client if needed (e.g., during disposal)
  void dispose() {
    AppHttpClient.instance.dispose();
  }
}
