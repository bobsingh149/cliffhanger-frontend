class ApiRoutePaths {
  static const String baseUrl = "http://localhost:7000/api";
  static const String userUrl = "$baseUrl/user";
  static const String bookUrl = "$baseUrl/product";
  static const String chatUrl = "$baseUrl/chat";
  static const String getAllProducts = "$bookUrl/getAllProducts";
  static const String getByBarterFilter = "$bookUrl/getByBarterFilter";
  static const String getPostsBySearch = "$bookUrl/getPostsBySearch";
  static const String getBookBuddies = "$userUrl/getBookBuddies";
  static const String getRequests = "$userUrl/getRequests";
  static const String getConnections = "$userUrl/getConnectionsByIds";
  static const String getBookBuddy = '/getBookBuddy';
  static const String updateUser = '/updateUser';
  static const String saveConnection = '/saveConnection';
  static const String getUserSetup = '/getUserSetup';
  static const String getCommonUsers = '/getCommonUsers';
  static const String saveRequest = '/saveRequest';
  static const String removeRequest = '/removeRequest';
  static const String deleteUser = '/deleteUserById';
  static const String getComments = '/getComments';
}

class ApiHeaders {
  static const multipartFormData = 'multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW';
}

class ApiRequestFields {
  static const file = 'file';
}

class ApiFileNames {
  static const profileImage = 'image.png';
  static const String groupImage = 'group_image.jpg';
}
