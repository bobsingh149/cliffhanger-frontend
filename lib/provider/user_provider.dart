// lib/providers/user_provider.dart

import 'package:barter_frontend/models/user_info.dart';
import 'package:barter_frontend/services/user_services.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService; // UserService instance
  UserInfo? _user; // User instance

  UserProvider({userService}) : _userService = userService ?? UserService();

  UserInfo? get user => _user; // Getter for user

  // Method to fetch user data from the API
  Future<void> fetchUser(String userId) async {
    try {
      _user = await _userService.fetchUser(userId);
      notifyListeners(); // Notify listeners to rebuild
    } catch (e) {
      print('Error fetching user: $e');
      // Handle errors appropriately (e.g., show a message)
    }
  }

  // Method to update user data
  Future<void> updateUser(UserInfo user) async {
    try {
      await _userService
          .saveUserInfo(user); // Assuming createUser updates if ID exists
      _user = user; // Update local user data
      notifyListeners(); // Notify listeners to rebuild
    } catch (e) {
      print('Error updating user: $e');
      // Handle errors appropriately
    }
  }

  // Optionally, you can have a method to clear user data
  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
