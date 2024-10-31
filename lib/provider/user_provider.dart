// lib/providers/user_provider.dart

import 'dart:typed_data';

import 'package:barter_frontend/models/contact.dart';
import 'package:barter_frontend/models/user_info.dart';
import 'package:barter_frontend/services/user_services.dart';
import 'package:barter_frontend/utils/app_logger.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService; // UserService instance
  final AppLogger _logger = AppLogger.instance;
  UserInfoModel? _user; // User instance

  UserProvider({userService})
      : _userService = userService ?? UserService.getInstance;

  UserInfoModel? get user => _user; // Getter for user

  bool isLoading = false;

  // Method to fetch user data from the API
  Future<void> fetchUser(String userId) async {
    try {
      isLoading = true;
      _user = await _userService.fetchUser(userId);
    } catch (e) {
      print('Error fetching user: $e');
      // Handle errors appropriately (e.g., show a message)
    } finally {
      isLoading = false;
      notifyListeners(); // Notify listeners to rebuild
    }
  }

  // Method to update user data
  Future<void> saveUser(UserInfoModel user, Uint8List? profileImage) async {
    isLoading = true;
    // notifyListeners();
    try {
      _logger.i('Saving user: $user');
      await _userService.saveUser(
          user, profileImage); // Assuming createUser updates if ID exists
      _user = user; // Update local user data
      _logger.i('User saved: $user');
    } catch (e) {
      _logger.e('Error updating user: $e');
      print('Error updating user: $e');
      // Handle errors appropriately
    } finally {
      isLoading = false;
      // notifyListeners(); // Notify listeners to rebuild
    }
  }

  // Optionally, you can have a method to clear user data
  void clearUser() {
    _user = null;
    notifyListeners();
  }

  Future<List<ContactModel>> getConnections() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Return dummy data with ContactModel
    return [
      ContactModel(
        conversationId: '1',
        isGroup: false,
        users: [
          UserInfoModel(
            id: '1',
            name: 'John Doe',
            profileImage: 'https://picsum.photos/200',
            age: 30,
            bio: 'Software Developer',
            city: 'New York',
          ),
        ],
        lastMessage: 'Hello there!',
        lastMessageTime: DateTime.now(),
      ),
      ContactModel(
        conversationId: '2',
        isGroup: false,
        users: [
          UserInfoModel(
            id: '2',
            name: 'Jane Smith',
            profileImage: null,
            age: 28,
            bio: 'UX Designer',
            city: 'San Francisco',
          ),
        ],
        lastMessage: 'Nice to meet you',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      ContactModel(
        conversationId: '3',
        isGroup: false,
        users: [
          UserInfoModel(
            id: '3',
            name: 'Bob Johnson',
            profileImage: 'https://picsum.photos/201',
            age: 35,
            bio: 'Product Manager',
            city: 'Chicago',
          ),
        ],
        lastMessage: 'See you tomorrow',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
  }

  Future<List<UserInfoModel>> getRequests() async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(
          const Duration(seconds: 1)); // Simulate network delay

      return [
        UserInfoModel(
          id: '1',
          name: 'Sarah Johnson',
          profileImage:
              'https://res.cloudinary.com/dllr1e6gn/image/upload/v1/postImages/lsousizd1yoccsmlrnvt',
          bio: 'Book lover',
          city: 'New York',
        ),
        UserInfoModel(
          id: '2',
          name: 'Mike Smith',
          profileImage:
              'https://res.cloudinary.com/dllr1e6gn/image/upload/v1729331643/profile_images/aemio6hooqxp1eiqzpev.jpg',
          bio: 'Tech enthusiast',
          city: 'San Francisco',
        ),
      ];
    } catch (e) {
      _logger.e('Error fetching requests: $e');
      rethrow;
    }
  }
}
