import 'package:barter_frontend/models/chat.dart';
import 'package:barter_frontend/provider/chat_provider.dart';
import 'package:barter_frontend/theme/theme.dart';
import 'package:barter_frontend/utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ChatProvider? _provider;
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _provider = Provider.of<ChatProvider>(context);
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: Text('Mansi'),
          centerTitle: true,
          elevation: 0,
        ),
        body: 

               Column(
                children: [
                  Expanded(
                    child: 

                    StreamBuilder<List<ChatModel>>(
            stream: _provider!.getMessages(""),
            builder: (context, snapshot) {
              // if (snapshot.connectionState == ConnectionState.waiting) {
              // }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No messages yet.',style: TextStyle(color: Colors.white),));
              }

              List<ChatModel> messages = snapshot.data!;
                    
                  return  ListView.builder(
                      reverse: true,
                      padding: EdgeInsets.all(10),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMe = message.from == "u1";
                        return _buildChatBubble(message.message, isMe,
                            message.timestamp);
                      },
                    );
            }
                    )

                  ),
                  _buildMessageInput(),
                ],
              ),
            );
  }

  Widget _buildChatBubble(String message, bool isMe, DateTime timestamp) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.secondaryColor : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: isMe ? Radius.circular(20) : Radius.zero,
            bottomRight: isMe ? Radius.zero : Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(2, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87, fontSize: 16),
            ),
            SizedBox(height: 5),
            Text(
             CommonUtils.formatDateTime(timestamp),
              style: TextStyle(
                  color: isMe ? Colors.white70 : Colors.black54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: EdgeInsets.all(10.r),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onSubmitted: (String value) {
                _sendMessage();
              },
              controller: _messageController,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.white,
                filled: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),
          SizedBox(width: 5),
          IconButton(
            onPressed: _sendMessage,
            icon: CircleAvatar(
              child: Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    await _provider!.sendMessage(
        ChatModel(
            from: "u1",
            to: ["u2", "u3"],
            message: _messageController.text.trim(),
            timestamp: DateTime.now()),
        "");

    setState(() {
      _messageController.clear();
    });
  }

  String _getTime() {
    return TimeOfDay.now().format(context);
  }
}
