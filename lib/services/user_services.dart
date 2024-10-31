import 'dart:convert';
import 'dart:typed_data';
import 'package:barter_frontend/constants/api_constants.dart';
import 'package:barter_frontend/models/user_info.dart';
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

  Future<UserInfoModel?> fetchUser(String userId) async {
    final response =
        await client.get(Uri.parse('${ApiRoutePaths.userUrl}/$userId'));

    if (response.statusCode == 200) {
      return UserInfoModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(ServiceUtils.parseErrorMessage(response));
    }
  }

  Future<void> saveUser(UserInfoModel user, Uint8List? profileImage) async {
    AppLogger.instance.e('Saving user: $user');

    var request = http.MultipartRequest(
        'POST', Uri.parse("${ApiRoutePaths.userUrl}/saveUser"));

    request.headers['Content-Type'] =
        'multipart/form-data; boundary=--------------------------592743729287522648443735';

    // Attach the JSON data as a field
    request.fields['data'] = jsonEncode(user.toJson());

    // Attach the image file if it exists
    if (profileImage != null) {
      final imageData = profileImage;
      request.files.add(
        http.MultipartFile.fromBytes(
            'file', // The field name expected by the server
            imageData!,
            filename: 'images.xyz'),
      );
    }

    AppLogger.instance.f('Request: fuckkkkkkkkkkkkkkkkkkkkkkkkkk');
    // Send the request and await the response
    final response = await request.send();
    final responseBody = await http.Response.fromStream(response);

    AppLogger.instance.i('Response: $responseBody');

    if (response.statusCode != 201) {
      throw Exception(ServiceUtils.parseErrorMessage(responseBody));
    }
  }

  // Close the client if needed (e.g., during disposal)
  void dispose() {
    AppHttpClient.instance.dispose();
  }
}
