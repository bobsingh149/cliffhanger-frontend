import 'dart:typed_data';

import 'package:barter_frontend/constants/api_constants.dart';
import 'package:barter_frontend/models/chat.dart';
import 'package:barter_frontend/models/user_setup.dart';
import 'package:barter_frontend/utils/app_logger.dart';
import 'package:barter_frontend/utils/http_client.dart';
import 'package:barter_frontend/utils/service_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class ChatService {
  final http.Client client;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ChatService({http.Client? client})
      : client = client ?? AppHttpClient.instance.client;

  static ChatService? _instance;

  static ChatService get getInstance {
    _instance ??= ChatService();

    return _instance!;
  }

  // Method to send a message using ChatModel
  Future<void> sendMessage({ required ChatModel chatModel, required String chatId}) async {
    
      try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(chatModel.toJson());
      print('Message sent successfully');
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  // Stream method to get messages for a specific chat ID
  Stream<List<ChatModel>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp',
            descending: true) // Order messages by time, newest first
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              // Convert each document to ChatModel
              return ChatModel.fromJson(doc.data() as Map<String, dynamic>);
            }).toList());
  }


  
  Future<String> uploadImage(Uint8List imageData) async {
    // Create a request
    var request = http.MultipartRequest(
        'POST', Uri.parse("${ApiRoutePaths.chatUrl}/uploadImage"));

    request.headers['Content-Type'] =
        'multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW';
    
      request.files.add(
        http.MultipartFile.fromBytes(
            'file', // The field name expected by the serve
            imageData,
            filename: 'image.any'),
      );
    

    // Send the request and await the response
    final response = await request.send();

    final responseBody = await http.Response.fromStream(response);

    if (response.statusCode >= 400) {
      throw Exception(ServiceUtils.parseErrorMessage(responseBody));
    }

  return ServiceUtils.parseResponse(responseBody);
    
    
  }

  Future<Map<String, ChatModel>> getLatestMessages(List<ConversationModel> conversationModels) async {
    Map<String, ChatModel> latestMessages = {};
    
    for (var conversation in conversationModels) {
      try {
        final querySnapshot = await _firestore
            .collection('chats')
            .doc(conversation.conversationId)
            .collection('messages')
            .orderBy('timestamp', descending: true) // Get newest message first
            .limit(1) // Only get the latest message
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final latestMessage = ChatModel.fromJson(
              querySnapshot.docs.first.data() as Map<String, dynamic>);
          latestMessages[conversation.conversationId] = latestMessage;
        }
      } catch (e) {
        AppLogger.instance.e("Error fetching latest message for conversation ${conversation.conversationId}: $e");
        }
    }
    
    return latestMessages;
  }

}
