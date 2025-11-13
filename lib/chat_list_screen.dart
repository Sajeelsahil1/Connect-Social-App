import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_connect/chat_screen.dart';
import 'package:social_connect/chat_service.dart';
import 'package:social_connect/theme.dart';
import 'package:intl/intl.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatService chatService = ChatService();
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: chatService.getChatList(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading chats.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('You have no messages yet.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final chatDoc = snapshot.data!.docs[index];
              final data = chatDoc.data() as Map<String, dynamic>;
              final List users = data['users'];

              final String otherUserId =
                  users.firstWhere((id) => id != currentUserId);
              final Timestamp lastTimestamp =
                  data['lastTimestamp'] ?? Timestamp.now();

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUserId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const ListTile(title: Text('Loading chat...'));
                  }

                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;
                  final String name = userData['name'] ?? 'User';
                  final String profilePic = userData['profilePictureUrl'] ?? '';

                  return ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage: profilePic.isNotEmpty
                          ? NetworkImage(profilePic)
                          : null,
                      child:
                          profilePic.isEmpty ? const Icon(Icons.person) : null,
                    ),
                    title: Text(name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      data['lastMessage'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      DateFormat('MMM d').format(lastTimestamp.toDate()),
                      style:
                          const TextStyle(color: subtitleColor, fontSize: 12),
                    ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          recipientId: otherUserId,
                          recipientName: name,
                          recipientProfilePic: profilePic,
                        ),
                      ));
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
