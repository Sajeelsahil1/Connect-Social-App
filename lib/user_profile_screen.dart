import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_connect/chat_screen.dart';
import 'package:social_connect/chat_service.dart';
import 'package:social_connect/post_card.dart';
import 'package:social_connect/theme.dart';

class UserProfileScreen extends StatelessWidget {
  final String userId;
  const UserProfileScreen({super.key, required this.userId});

  void _startChat(BuildContext context, String recipientId,
      String recipientName, String recipientProfilePic) async {
    final ChatService chatService = ChatService();
    final chatRoomId = await chatService.getChatRoomId(recipientId);

    if (context.mounted) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ChatScreen(
          recipientId: recipientId,
          recipientName: recipientName,
          recipientProfilePic: recipientProfilePic,
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMyProfile = FirebaseAuth.instance.currentUser!.uid == userId;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('User not found.'));
            }

            Map<String, dynamic> userData =
                snapshot.data!.data() as Map<String, dynamic>;
            String name = userData['name'] ?? 'No Name';
            String bio = userData['bio'] ?? 'No Bio';
            String profilePic = userData['profilePictureUrl'] ?? '';

            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: profilePic.isNotEmpty
                                ? NetworkImage(profilePic)
                                : null,
                            child: profilePic.isEmpty
                                ? const Icon(Icons.person, size: 50)
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            name,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            bio,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: subtitleColor),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          if (!isMyProfile)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.chat_bubble_outline),
                                label: const Text('Message'),
                                onPressed: () {
                                  _startChat(context, userId, name, profilePic);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: cardColor,
                                  foregroundColor: textColor,
                                ),
                              ),
                            ),
                          const Divider(height: 40),
                          Text(
                            "$name's Posts",
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .where('uid', isEqualTo: userId)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, postSnapshot) {
                  if (postSnapshot.hasError) {
                    return Center(child: Text('Error: ${postSnapshot.error}'));
                  }
                  if (postSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!postSnapshot.hasData ||
                      postSnapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('This user hasn\'t posted yet.'),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: postSnapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var post = postSnapshot.data!.docs[index];
                      Map<String, dynamic> postData =
                          post.data() as Map<String, dynamic>;

                      return PostCard(
                        postId: post.id,
                        uid: userId,
                        name: name,
                        profilePic: profilePic,
                        postText: postData['postText'] ?? '',
                        timestamp: postData['timestamp'] ?? Timestamp.now(),
                        likes: postData['likes'] ?? [],
                        fileUrl: postData['fileUrl'],
                        fileType: postData['fileType'],
                        onProfileTap: () {},
                      );
                    },
                  );
                },
              ),
            );
          },
        ));
  }
}
