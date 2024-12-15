import 'dart:convert';

import 'package:http/http.dart';

class ServiceUtils {
  static String parseErrorMessage(Response response) {
    return jsonDecode(response.body)["errorMessage"];
  }

  static dynamic parseResponse(Response response) {
    return jsonDecode(response.body)["data"];
  }

}
