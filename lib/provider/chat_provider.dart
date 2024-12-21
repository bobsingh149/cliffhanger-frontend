import 'dart:typed_data';

import 'package:barter_frontend/models/chat.dart';
import 'package:barter_frontend/services/chat_serivces.dart';
import 'package:barter_frontend/utils/app_logger.dart';
import 'package:flutter/material.dart';

class ChatProvider with ChangeNotifier {
  final AppLogger _logger = AppLogger.instance;
  final ChatService _chatService;

  ChatProvider({ChatService? chatService})
      : _chatService = chatService ?? ChatService.getInstance;

  Future<void> sendMessage(ChatModel chatModel, String chatId) async {
    try {
      await _chatService.sendMessage(
          chatModel: chatModel, chatId: chatId);
      _logger.i("success");
    } catch (err) {
      _logger.e(err.toString());
    }
  }

  Stream<List<ChatModel>> getMessages(String chatId) {
    return _chatService.getMessages(chatId);
  }

  Future<String> uploadImage(Uint8List imageData) async {
    try {
      return await _chatService.uploadImage(imageData);
    } catch (err) {
      _logger.e(err.toString());
      rethrow;
    }
  }

  Future<void> sendImageMessage({required ChatModel chatModel, required String chatId, required Uint8List imageData}) async {
    try {
      chatModel.imageUrl = await uploadImage(imageData);
      return await sendMessage(chatModel, chatId);
    } catch (err) {
      _logger.e(err.toString());
      rethrow;
    }
  }
}
