import 'dart:convert';

import 'dart:async';

import 'package:stomp_dart_client/stomp_dart_client.dart';

class ChatInput {
  final String from;
  final String to;
  final String message;
  final bool isRead;
  final bool isEdited;

  ChatInput(this.from, this.to, this.message, this.isRead, this.isEdited);

  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'to': to,
      'message': message,
      'isRead': isRead,
      'isEdited': isEdited,
    };
  }
}

class WebSocketService {
  static final stompClient = StompClient(
    config: StompConfig(
      url: 'ws://10.0.2.2:8080/api',

      onConnect: onConnect,
      beforeConnect: () async {
        print('waiting to connect...');
        await Future.delayed(const Duration(milliseconds: 200));
        print('connecting...');
      },
      onWebSocketError: (dynamic error) => print(error.toString()),
      // stompConnectHeaders: {'Authorization': 'Bearer yourToken'},
      // webSocketConnectHeaders: {'Authorization': 'Bearer yourToken'},
    ),
  );

  static void onConnect(StompFrame frame) {
    // Create a sample ChatInput instance
    final chatInput = ChatInput(
      "u1", // Generate a random UUID for 'from'
      "u2", // Generate a random UUID for 'to'
      'Hello, this is a test message!',
      false,
      false,
    );

    // Send the ChatInput request as JSON
    final request = jsonEncode(chatInput.toJson());

    stompClient.subscribe(
      destination: '/topic/1',
      callback: (frame) {
        List<dynamic>? result = json.decode(frame.body!);
        print(result);
      },
    );

    Timer.periodic(const Duration(seconds: 1), (_) {
      stompClient.send(
        destination: '/sendMessage/1',
        body: request,
      );
    });
  }

  static Future<void> sendMessage() async {
    stompClient.activate();
  }
}
