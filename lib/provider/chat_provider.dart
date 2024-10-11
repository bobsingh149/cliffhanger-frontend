import 'package:barter_frontend/models/chat.dart';
import 'package:barter_frontend/services/chat_serivces.dart';
import 'package:barter_frontend/utils/app_logger.dart';
import 'package:flutter/material.dart';

class ChatProvider with ChangeNotifier {
  final AppLogger _logger = AppLogger.instance;
  bool isLoading = false;
  final ChatService _chatService;

  ChatProvider({ChatService? chatService})
      : _chatService = chatService ?? ChatService.getInstance;

  Future<void> sendMessage(ChatModel chatModel, String chatId) async {
    try {
      await _chatService.sendMessage(
          chatModel: chatModel, chatId: "e7933408-284c-4c99-b5ab-16834feca8be");
      _logger.i("success");
    } catch (err) {
      _logger.e(err.toString());
    }
  }

  Stream<List<ChatModel>> getMessages(String chatId) {
    return _chatService.getMessages("e7933408-284c-4c99-b5ab-16834feca8be");
  }
}
