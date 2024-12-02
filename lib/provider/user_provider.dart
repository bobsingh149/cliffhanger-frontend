// lib/providers/user_provider.dart

import 'dart:typed_data';

import 'package:barter_frontend/models/chat.dart';
import 'package:barter_frontend/models/contact.dart';
import 'package:barter_frontend/models/user.dart';
import 'package:barter_frontend/models/save_conversation_input.dart';
import 'package:barter_frontend/models/save_request_input.dart';
import 'package:barter_frontend/models/user_setup.dart';
import 'package:barter_frontend/services/auth_services.dart';
import 'package:barter_frontend/services/chat_serivces.dart';
import 'package:barter_frontend/services/user_services.dart';
import 'package:barter_frontend/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart'
    if (dart.library.io) 'package:barter_frontend/utils/mock_image_picker_web.dart';
import 'package:flutter/foundation.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService; // UserService instance
  final AppLogger _logger = AppLogger.instance;
  UserSetupModel? _user; // User instance
  List<ContactModel>? _contacts;
  Uint8List? groupImageData;
  bool isLoading = false;

  UserProvider({userService})
      : _userService = userService ?? UserService.getInstance;

  UserSetupModel? get user => _user; // Getter for user

  List<ContactModel>? get contacts => _contacts;

  // Method to fetch user data from the API
  Future<UserModel?> fetchUser(String userId) async {
    try {
      return await _userService.fetchUser(userId);
    } catch (e) {
      _logger.e('Error fetching user: $e');
      rethrow;
    }
  }

  // Method to update user data
  Future<void> saveUser(UserModel user, Uint8List? profileImage) async {
    try {
      await _userService.saveUser(user, profileImage);
    } catch (e) {
      _logger.e('Error updating user: $e');
      rethrow;
    }
  }

  Future<UserModel> getBookBuddy() async {
    try {
      return await _userService.getBookBuddy(_user?.id ?? '');
    } catch (e) {
      _logger.e('Error fetching book buddy: $e');
      rethrow;
    }
  }

  // Method to update user data
  Future<void> updateUser(UserModel user, Uint8List? profileImage) async {
    try {
      await _userService.updateUser(user, profileImage);
      clearUser();
    } catch (e) {
      _logger.e('Error updating user: $e');
      rethrow;
    }
  }

  // Method to save a connection
  Future<void> saveConnection(SaveConversationInput input) async {
    try {
      await _userService.saveConnection(input);
    } catch (e) {
      _logger.e('Error saving connection: $e');
      rethrow;
    }
  }

  // Method to get user setup
  Future<UserSetupModel> getUserSetup(String userId) async {
    try {
      return _user = await _userService.getUserSetup(userId);
    } catch (e) {
      _logger.e('Error fetching user setup: $e');
      rethrow;
    }
  }

  // Method to get common users
  Future<List<UserModel>> getCommonUsers(String userId,
      {required int page, required int size}) async {
    try {
      return await _userService.getCommonUsers(userId, page: page, size: size);
    } catch (e) {
      _logger.e('Error fetching common users: $e');
      rethrow;
    }
  }

  // Method to save a request
  Future<void> saveRequest(SaveRequestInput input) async {
    try {
      await _userService.saveRequest(input);
    } catch (e) {
      _logger.e('Error saving request: $e');
      rethrow;
    }
  }

  // Method to remove a request
  Future<void> removeRequest(SaveRequestInput input) async {
    try {
      await _userService.removeRequest(input);
    } catch (e) {
      _logger.e('Error removing request: $e');
      rethrow;
    }
  }

  // Method to delete a user
  Future<void> deleteUser(String userId) async {
    try {
      await _userService.deleteUser(userId);
      clearUser(); // Clear local user data
    } catch (e) {
      _logger.e('Error deleting user: $e');
      rethrow;
    }
  }

  Future<List<RequestModel>> getRequests() async {
    if (_user == null) {
      // If _user is null, fetch user setup first
      await getUserSetup(AuthService.getInstance.currentUser!.uid);
    }
    return _user?.requests ?? [];
  }

  Future<List<BookBuddy>> getBookBuddies({bool forceRefresh = false}) async {
    if (_user == null || forceRefresh) {
      await getUserSetup(AuthService.getInstance.currentUser!.uid);
    }
    return _user?.bookBuddies ?? [];
  }

  Future<List<ContactModel>> getConnections() async {
    if (_contacts != null) {
      return _contacts!;
    }

    if (_user == null) {
      await getUserSetup(AuthService.getInstance.currentUser!.uid);
    }
    List<ConversationModel> conversationModels = _user?.conversations ?? [];

    // Get latest messages for all conversations
    Map<String, ChatModel> latestMessages =
        await ChatService.getInstance.getLatestMessages();

    List<ContactModel> connections = conversationModels.map((conversation) {
      // Get the latest message for this conversation
      ChatModel? latestChat = latestMessages[conversation.conversationId];

      return ContactModel(
        conversationId: conversation.conversationId,
        isGroup: conversation.isGroup,
        users: conversation.users,
        lastMessage: latestChat?.message,
        lastMessageTime: latestChat?.timestamp,
        groupName: conversation.groupName,
        groupImage: conversation.groupImage,
      );
    }).toList();

    return _contacts = connections;
  }

  // Optionally, you can have a method to clear user data
  void clearUser() {
    _user = null;
    _contacts = null;

    notifyListeners();
  }

  Future<void> pickGroupImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      if (kIsWeb) {
        groupImageData = await ImagePickerWeb.getImageAsBytes();
      } else {
        final pickedFile = await picker.pickImage(source: source);
        if (pickedFile != null) {
          groupImageData = await pickedFile.readAsBytes();
        }
      }
      notifyListeners();
    } catch (e) {
      _logger.e('Error picking image: $e');
      rethrow;
    }
  }

  void removeGroupImage() {
    groupImageData = null;
    notifyListeners();
  }

  Future<void> createGroup({
    required String name,
    required List<String> memberIds,
    String? description,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      await _userService.createGroup(
        name: name,
        memberIds: memberIds,
        description: description,
        groupImage: groupImageData,
      );
      groupImageData = null;
    } catch (e) {
      _logger.e('Error creating group: $e');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<List<ContactModel>> getMockConnections() async {
    return [
      ContactModel(
        conversationId: 'conv1',
        isGroup: false,
        users: [
          UserModel(
            id: 'user1',
            name: 'Sarah Wilson',
            profileImage: 'https://picsum.photos/200?random=10',
          ),
        ],
        lastMessage: 'Hey, have you read the new book I recommended?',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      ContactModel(
        conversationId: 'conv2',
        isGroup: true,
        users: [
          UserModel(
            id: 'user2',
            name: 'Book Club Members',
            profileImage: 'https://picsum.photos/200?random=11',
          ),
        ],
        lastMessage: 'Next meeting is on Friday!',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
        groupName: 'Fantasy Book Club',
        groupImage: 'https://picsum.photos/200?random=12',
      ),
      ContactModel(
        conversationId: 'conv3',
        isGroup: false,
        users: [
          UserModel(
            id: 'user3',
            name: 'David Chen',
            profileImage: 'https://picsum.photos/200?random=13',
          ),
        ],
        lastMessage: 'Thanks for the book exchange!',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      ContactModel(
        conversationId: 'conv4',
        isGroup: false,
        users: [
          UserModel(
            id: 'user4',
            name: 'Emily Parker',
            profileImage: 'https://picsum.photos/200?random=14',
          ),
        ],
        lastMessage: 'Did you finish the chapter?',
        lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ContactModel(
        conversationId: 'conv5',
        isGroup: true,
        users: [
          UserModel(
            id: 'user5',
            name: 'Mystery Readers',
            profileImage: 'https://picsum.photos/200?random=15',
          ),
        ],
        lastMessage: 'Who else figured out the killer?',
        lastMessageTime: DateTime.now().subtract(const Duration(days: 2)),
        groupName: 'Mystery Book Club',
        groupImage: 'https://picsum.photos/200?random=16',
      ),
      ContactModel(
        conversationId: 'conv6',
        isGroup: false,
        users: [
          UserModel(
            id: 'user6',
            name: 'Alex Thompson',
            profileImage: 'https://picsum.photos/200?random=17',
          ),
        ],
        lastMessage: 'Looking forward to our book discussion!',
        lastMessageTime: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }
}
