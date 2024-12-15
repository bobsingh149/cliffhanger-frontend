import 'package:barter_frontend/models/chat.dart';
import 'package:barter_frontend/models/contact.dart';
import 'package:barter_frontend/models/user.dart';
import 'package:barter_frontend/provider/chat_provider.dart';
import 'package:barter_frontend/services/auth_services.dart';
import 'package:barter_frontend/theme/theme.dart';
import 'package:barter_frontend/utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart'
    if (dart.library.io) 'package:barter_frontend/utils/mock_image_picker_web.dart';

class ChatScreen extends StatefulWidget {
  static const routePath = '/chat';
  final ContactModel contact;

  const ChatScreen({
    Key? key,
    required this.contact,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ChatProvider? _provider;
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  Uint8List? _imageData;

  @override
  Widget build(BuildContext context) {
    _provider = Provider.of<ChatProvider>(context);
    return Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? AppTheme
                .backgroundColorGrey // Light grey background for light mode
            : null, // Keep default dark mode background
        body: SafeArea(
          child: Column(
            children: [
              AppBar(
                title: Text(widget.contact.getDisplayName()),
                centerTitle: true,
              ),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                        child: StreamBuilder<List<ChatModel>>(
                            stream: _provider!.getMessages(""),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              List<ChatModel> messages = snapshot.data!;
                              // Group messages by date
                              Map<String, List<ChatModel>> groupedMessages = {};

                              for (var message in messages) {
                                String dateKey = CommonUtils.formatDateOnly(
                                    message.timestamp);
                                groupedMessages.putIfAbsent(dateKey, () => []);
                                groupedMessages[dateKey]!.add(message);
                              }

                              return ListView.builder(
                                reverse: true,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 10.h),
                                itemCount: groupedMessages.length,
                                itemBuilder: (context, index) {
                                  String dateKey =
                                      groupedMessages.keys.elementAt(index);
                                  List<ChatModel> dayMessages =
                                      groupedMessages[dateKey]!;

                                  return Column(
                                    children: [
                                      _buildDateHeader(dateKey),
                                      ...dayMessages.map((message) {
                                        final isMe = message.from !=
                                            AuthService
                                                .getInstance.currentUser!.uid;
                                        return _buildChatBubble(message, isMe);
                                      }).toList(),
                                    ],
                                  );
                                },
                              );
                            })),
                    _buildMessageInput(),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildChatBubble(ChatModel chatMessage, bool isMe) {
    final DateTime timestamp = chatMessage.timestamp;
    Widget? senderInfo;
    if (widget.contact.isGroup && !isMe) {
      // Find the user info from the contact's users list
      UserModel? sender = widget.contact.users.firstWhere(
        (user) =>
            user.id ==
            chatMessage
                .from, // You'll need to add 'from' field to your message data
        orElse: () => UserModel(id: '', name: 'Unknown User'),
      );

      senderInfo = Padding(
        padding: EdgeInsets.only(bottom: 4.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (sender.profileImage != null)
              CircleAvatar(
                radius: 12.r,
                backgroundImage: NetworkImage(sender.profileImage!),
              ),
            SizedBox(width: 8.w),
            Text(
              sender.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.87)
                    : Colors.black.withOpacity(0.87),
              ),
            ),
          ],
        ),
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5.h),
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
          maxHeight: chatMessage.isImage ? 200.h : double.infinity,
        ),
        decoration: BoxDecoration(
          color: isMe
              ? AppTheme.secondaryColor
              : Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[900]
                  : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(20),
          ),
          boxShadow: const [
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
          mainAxisSize: MainAxisSize.min,
          children: [
            if (senderInfo != null) senderInfo,
            if (chatMessage.isImage && chatMessage.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: chatMessage.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      chatMessage.message,
                      style: TextStyle(
                          color: isMe
                              ? Colors.white
                              : Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white.withOpacity(0.87)
                                  : Colors.black.withOpacity(0.87),
                          fontSize: 16),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    CommonUtils.formatTime(timestamp),
                    style: TextStyle(
                        color: isMe
                            ? Colors.white.withOpacity(0.7)
                            : Theme.of(context).brightness == Brightness.dark
                                ? Colors.white.withOpacity(0.54)
                                : Colors.black.withOpacity(0.54),
                        fontSize: 12),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onSubmitted: (String value) {
                _sendMessage();
              },
              controller: _messageController,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black87),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: Icon(Icons.photo_library),
                    ),
                    if (!kIsWeb) // Only show camera button on mobile
                      IconButton(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: Icon(Icons.camera_alt),
                      ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 1.w),
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
            from: AuthService.getInstance.currentUser!.uid,
            message: _messageController.text.trim(),
            isImage: false,
            timestamp: DateTime.now()),
        widget.contact.conversationId);

    setState(() {
      _messageController.clear();
    });
  }

  String _getTime() {
    return TimeOfDay.now().format(context);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (kIsWeb) {
        final pickedFile = await ImagePickerWeb.getImageAsBytes();
        if (pickedFile != null) {
          setState(() {
            _imageData = pickedFile;
          });
          // Handle sending image message
          await _sendImageMessage(_imageData!);
        }
      } else {
        final XFile? pickedFile = await _picker.pickImage(source: source);
        if (pickedFile != null) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _imageData = bytes;
          });
          // Handle sending image message
          await _sendImageMessage(bytes);
        }
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _sendImageMessage(Uint8List imageData) async {
    await _provider!.sendImageMessage(
        ChatModel(
            from: AuthService.getInstance.currentUser!.uid,
            message: _messageController.text.trim(),
            isImage: true,
            timestamp: DateTime.now()),
        widget.contact.conversationId,
        imageData);
  }

  Widget _buildDateHeader(String date) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            date,
            style: TextStyle(
              fontSize: 12.sp,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
