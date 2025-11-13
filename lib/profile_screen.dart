import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_connect/edit_profile_screen.dart';
import 'package:social_connect/grid_post_tile.dart';
import 'package:social_connect/post_card.dart';
import 'package:social_connect/settings_provider.dart';
import 'package:social_connect/settings_screen.dart';
import 'package:social_connect/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final User currentUser = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    _checkAndCreateProfile();
  }

  Future<void> _checkAndCreateProfile() async {
    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(currentUserId);
    final doc = await userDocRef.get();

    if (!doc.exists) {
      try {
        await userDocRef.set({
          'uid': currentUserId,
          'name': currentUser.displayName ?? 'New User',
          'bio': '',
          'profilePictureUrl': currentUser.photoURL ?? '',
          'email': currentUser.email ?? '',
        });
      } catch (e) {
        // Error
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('My Profile'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Settings',
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ));
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('Creating profile...'));
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
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      EditProfileScreen(userData: userData),
                                ));
                              },
                              child: const Text('Edit Profile'),
                            ),
                          ),
                          const Divider(height: 40),
                          Text(
                            'My Posts',
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
                    .where('uid', isEqualTo: currentUserId)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, postSnapshot) {
                  if (postSnapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'Error: ${postSnapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  if (postSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!postSnapshot.hasData ||
                      postSnapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('Your posts will appear here.'),
                      ),
                    );
                  }

                  return Consumer<SettingsProvider>(
                    builder: (context, settings, child) {
                      if (settings.isGridView) {
                        return GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 6,
                            mainAxisSpacing: 6,
                          ),
                          itemCount: postSnapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            var post = postSnapshot.data!.docs[index];
                            Map<String, dynamic> postData =
                                post.data() as Map<String, dynamic>;

                            return GridPostTile(postData: postData);
                          },
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
                            uid: currentUserId,
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
                  );
                },
              ),
            );
          },
        ));
  }
}
