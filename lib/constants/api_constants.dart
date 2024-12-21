class ApiRoutePaths {
  static const String baseUrl = "https://barter-backend-w0ef.onrender.com/api";
  // static const String baseUrl = "http://localhost:7000/api";
  static const String userUrl = "$baseUrl/user";
  static const String bookUrl = "$baseUrl/product";
  static const String chatUrl = "$baseUrl/chat";
  static const String getUser = "$userUrl/getUserById";
  static const String getAllProducts = "$bookUrl/getAllProducts";
  static const String getByBarterFilter = "$bookUrl/getByBarterFilter";
  static const String getPostsBySearch = "$bookUrl/getPostsBySearch";
  static const String getBookBuddies = "$userUrl/getBookBuddies";
  static const String getRequests = "$userUrl/getRequests";
    static const String getConnections = "$userUrl/getConnectionsByIds";
  static const String getBookBuddy = "$userUrl/getBookBuddy";
  static const String updateUser = "$userUrl/updateUser";
  static const String saveConnection = "$userUrl/saveConnection";
  static const String saveGroup = "$userUrl/saveGroup";
  static const String getUserSetup = "$userUrl/getUserSetup";
  static const String getCommonUsers = "$userUrl/getCommonUsers";
  static const String saveRequest = "$userUrl/saveRequest";
  static const String removeRequest = "$userUrl/removeRequest";
  static const String deleteUser = "$userUrl/deleteUserById";
  static const String getComments = "$bookUrl/getComments";
  static const String saveUser = "$userUrl/saveUser";
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
