import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_connect/create_post_screen.dart';
// CHANGED: Import the ProfileScreen we just updated (with the Follow logic)
import 'package:social_connect/profile_screen.dart';
import 'package:social_connect/post_card.dart';
import 'package:social_connect/search_screen.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  Future<DocumentSnapshot> getUserData(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kinekt',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const SearchScreen(),
              ));
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const CreatePostScreen(),
          ));
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No posts yet. Be the first!'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var post = snapshot.data!.docs[index];
              Map<String, dynamic> postData =
                  post.data() as Map<String, dynamic>;

              String postText = postData['postText'] ?? '';
              // This UID is the person who created the post
              String uid = postData['uid'] ?? '';
              Timestamp timestamp = postData['timestamp'] ?? Timestamp.now();
              List likes = postData['likes'] ?? [];
              String? fileUrl = postData['fileUrl'];
              String? fileType = postData['fileType'];

              return FutureBuilder<DocumentSnapshot>(
                future: getUserData(uid),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            const CircleAvatar(
                                radius: 20, backgroundColor: Colors.grey),
                            const SizedBox(width: 10),
                            Container(
                                height: 10, width: 100, color: Colors.grey),
                          ],
                        ),
                      ),
                    );
                  }

                  String name;
                  String profilePic;

                  if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                    name = 'Unknown User';
                    profilePic = '';
                  } else {
                    Map<String, dynamic>? userData =
                        userSnapshot.data!.data() as Map<String, dynamic>?;
                    name = userData?['name'] ?? 'User';
                    profilePic = userData?['profilePictureUrl'] ?? '';
                  }

                  return PostCard(
                    postId: post.id,
                    uid: uid,
                    name: name,
                    profilePic: profilePic,
                    postText: postText,
                    timestamp: timestamp,
                    likes: likes,
                    fileUrl: fileUrl,
                    fileType: fileType,
                    onProfileTap: () {
                      // FIX: Navigate to ProfileScreen with the post creator's UID
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ProfileScreen(uid: uid),
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
