import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_connect/chat_service.dart';
import 'package:social_connect/message_bubble.dart';
import 'package:social_connect/theme.dart';

class ChatScreen extends StatefulWidget {
  final String recipientId;
  final String recipientName;
  final String recipientProfilePic;

  const ChatScreen({
    super.key,
    required this.recipientId,
    required this.recipientName,
    required this.recipientProfilePic,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  String _chatRoomId = '';
  bool _isLoading = true;
  bool _isSending = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _getChatRoom();
  }

  void _getChatRoom() async {
    final chatRoomId = await _chatService.getChatRoomId(widget.recipientId);
    setState(() {
      _chatRoomId = chatRoomId;
      _isLoading = false;
    });
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    setState(() {
      _isSending = true;
    });

    String message = _messageController.text;
    _messageController.clear();

    await _chatService.sendMessage(widget.recipientId, _chatRoomId, message);
    setState(() {
      _isSending = false;
    });
  }

  Future<void> _sendMedia(bool isVideo) async {
    final XFile? file;
    if (isVideo) {
      file = await _picker.pickVideo(source: ImageSource.gallery);
    } else {
      file = await _picker.pickImage(source: ImageSource.gallery);
    }

    if (file != null) {
      setState(() {
        _isSending = true;
      });
      await _chatService.sendMediaMessage(
          widget.recipientId, _chatRoomId, file, isVideo);
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: widget.recipientProfilePic.isNotEmpty
                  ? NetworkImage(widget.recipientProfilePic)
                  : null,
              child: widget.recipientProfilePic.isEmpty
                  ? const Icon(Icons.person, size: 18)
                  : null,
            ),
            const SizedBox(width: 10),
            Text(widget.recipientName),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // --- Messages List ---
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _chatService.getMessages(_chatRoomId),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(child: Text('Error'));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return ListView(
                        reverse: true,
                        padding: const EdgeInsets.all(10),
                        children: snapshot.data!.docs
                            .map((doc) => _buildMessageItem(doc))
                            .toList(),
                      );
                    },
                  ),
                ),
                // --- Message Input ---
                _buildMessageInput(),
              ],
            ),
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final bool isMe = data['senderId'] == _currentUserId;

    return MessageBubble(
      message: data['message'],
      type: data['type'],
      isMe: isMe,
      timestamp: data['timestamp'],
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: _isSending ? null : () => _sendMedia(false),
          ),
          if (!kIsWeb) // Video picking on web is different
            IconButton(
              icon: const Icon(Icons.videocam),
              onPressed: _isSending ? null : () => _sendMedia(true),
            ),
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
                filled: false,
              ),
            ),
          ),
          IconButton(
            icon: _isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.send, color: primaryColor),
            onPressed: _isSending ? null : _sendMessage,
          ),
        ],
      ),
    );
  }
}
