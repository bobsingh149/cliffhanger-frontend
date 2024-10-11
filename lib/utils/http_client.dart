import 'package:http/http.dart' as http;

// Singleton class to hold the client instance
class AppHttpClient {
  // Private constructor
  AppHttpClient._internal();

  // The single shared instance
  static final AppHttpClient _instance = AppHttpClient._internal();

  // Public accessor for the instance
  static AppHttpClient get instance => _instance;

  // The reusable HTTP client
  final http.Client client = http.Client();

  // Dispose method to close the client when no longer needed
  void dispose() {
    client.close();
  }
}

