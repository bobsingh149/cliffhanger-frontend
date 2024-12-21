// lib/providers/user_provider.dart
import 'package:barter_frontend/exceptions/user_exceptions.dart';
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
      clearUserSetup();
    } catch (e) {
      _logger.e('Error updating user: $e');
      rethrow;
    }
  }

  Future<GetBookBuddy> getBookBuddy() async {
    try {
      clearUserSetup();
      return await _userService
          .getBookBuddy(AuthService.getInstance.currentUser!.uid);
    } catch (e) {
      _logger.e('Error fetching book buddy: $e');
      rethrow;
    }
  }

  // Method to update user data
  Future<void> updateUser(UserModel user, Uint8List? profileImage) async {
    try {
      await _userService.updateUser(user, profileImage);
      clearUserSetup();
    } catch (e) {
      _logger.e('Error updating user: $e');
      rethrow;
    }
  }

  // Method to save a connection
  Future<void> saveConnection(SaveConversationInput input) async {
    try {
      await _userService.saveConnection(input);
      clearUserSetup();
    } catch (e) {
      _logger.e('Error saving connection: $e');
      rethrow;
    }
  }

  void clearUserSetup() {
    _user = null;
    _contacts = null;
    notifyListeners();
  }

  // Method to get user setup
  Future<UserSetupModel> getUserSetup(String userId) async {
    if (_user != null) {
      return _user!;
    }

    try {
      _logger.i('Fetching user setup for $userId');
      _user = await _userService.getUserSetup(userId);

      if (_user == null) {
        throw UserNotFoundException(userId, 'User setup not found');
      }

      return _user!;
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
      clearUserSetup();
    } catch (e) {
      _logger.e('Error saving request: $e');
      rethrow;
    }
  }

  // Method to remove a request
  Future<void> removeRequest(SaveRequestInput input) async {
    try {
      await _userService.removeRequest(input);
      clearUserSetup();
    } catch (e) {
      _logger.e('Error removing request: $e');
      rethrow;
    }
  }

  // Method to delete a user
  Future<void> deleteUser(String userId) async {
    try {
      await _userService.deleteUser(userId);
      clearUserSetup(); // Clear local user data
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
      // Add a delay of 2 seconds
      await getUserSetup(AuthService.getInstance.currentUser!.uid);
    }
    return _user?.bookBuddies ?? [];
  }

  Future<List<ConversationModel>> getNonGroupContacts() async {
    if (_user == null) {
      await getUserSetup(AuthService.getInstance.currentUser!.uid);
    }
    List<ConversationModel> conversationModels = _user?.conversations ?? [];

    conversationModels = conversationModels
        .where((conversation) => !conversation.isGroup)
        .toList();

    AppLogger.instance.i("conversationModels: ${conversationModels.length}");

    return conversationModels;
  }

  Future<List<ContactModel>> getAllContacts() async {
    if (_user == null) {
      await getUserSetup(AuthService.getInstance.currentUser!.uid);
    }
    List<ConversationModel> conversationModels = _user?.conversations ?? [];

    // Get latest messages for all conversations
    Map<String, ChatModel> latestMessages =
        await ChatService.getInstance.getLatestMessages(conversationModels);

    AppLogger.instance.i("latestMessages: $latestMessages");

    List<ContactModel> connections = conversationModels.map((conversation) {
      // Get the latest message for this conversation
      ChatModel? latestChat = latestMessages[conversation.conversationId];

      return ContactModel(
        conversationId: conversation.conversationId,
        isGroup: conversation.isGroup,
        users: [
          ...conversation.members,
          if (conversation.userResponse != null) conversation.userResponse!
        ],
        lastMessage: latestChat?.message,
        lastMessageTime: latestChat?.timestamp,
        groupName: conversation.groupName,
        groupImage: conversation.groupImage,
        userResponse: conversation.userResponse,
      );
    }).toList();

    return _contacts = connections;
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
      clearUserSetup();
    } catch (e) {
      _logger.e('Error creating group: $e');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setGroupImage(Uint8List imageData) async {
    groupImageData = imageData;
    notifyListeners();
  }
}
