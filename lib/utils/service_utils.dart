import 'dart:convert';

import 'package:http/http.dart';

class ServiceUtils {
  static parseErrorMessage(Response response) {
    return jsonDecode(response.body)["errorMessage"];
  }

  static parseResponse(Response response) {
    return jsonDecode(response.body)["data"];
  }

}
