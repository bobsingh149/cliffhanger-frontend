import 'dart:convert';

import 'package:barter_frontend/constants/api_constants.dart';
import 'package:barter_frontend/models/book.dart';
import 'package:barter_frontend/utils/http_client.dart';
import 'package:barter_frontend/utils/service_utils.dart';
import 'package:http/http.dart' as http;

class BookService {
  final http.Client client;
  static BookService? _instance;

  BookService({http.Client? client})
      : client = client ?? AppHttpClient.instance.client;

  static BookService get getInstance {
    _instance ??= BookService();

    return _instance!;
  }

  Future<List<Book>> getResults(String query) async {
    final response = await client
        .get(Uri.parse("${ApiRoutePaths.bookUrl}/getSearchResults").replace(
      queryParameters: {"q": query},
    ));

    if (response.statusCode == 200) {
      Map<String, dynamic> bookresponse = jsonDecode(response.body);

      List<dynamic> bookList = bookresponse["data"];

      return bookList.map((book) => Book.fromJson(book)).toList();
    } else {
      throw Exception(ServiceUtils.parseErrorMessage(response));
    }
  }

  Future<void> postBook(SavePost userBook) async {
    // Create a request
    var request = http.MultipartRequest(
        'POST', Uri.parse("${ApiRoutePaths.bookUrl}/saveProduct"));

    request.headers['Content-Type'] =
        'multipart/form-data; boundary=--------------------------592743729287522648443735';

    // Attach the JSON data as a field
    request.fields['data'] = jsonEncode(userBook.toJson());

    // Attach the image file if it exists
    if (userBook.postImage != null) {
      final imageData = userBook.postImage;
      request.files.add(
        http.MultipartFile.fromBytes(
            'file', // The field name expected by the server
            imageData!,
            filename: 'image.any'),
      );
    }

    // Send the request and await the response
    final response = await request.send();

    final responseBody = await http.Response.fromStream(response);

    if (response.statusCode != 201) {
      throw Exception(ServiceUtils.parseErrorMessage(responseBody));
    }
  }

  void dispose() {
    AppHttpClient.instance.dispose();
  }
}
