import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_connect/chat_screen.dart';
import 'package:social_connect/edit_profile_screen.dart';
import 'package:social_connect/follow_service.dart';
import 'package:social_connect/grid_post_tile.dart';
import 'package:social_connect/post_card.dart';
import 'package:social_connect/settings_provider.dart';
import 'package:social_connect/settings_screen.dart';
import 'package:social_connect/theme.dart';

class ProfileScreen extends StatefulWidget {
  final String? uid; // If null, it loads the current logged-in user

  const ProfileScreen({super.key, this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String profileUserId;
  late bool isMe;
  final FollowService _followService = FollowService();

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;

    // 1. Determine whose profile we are looking at
    if (widget.uid != null && widget.uid != currentUser!.uid) {
      // Viewing someone else
      profileUserId = widget.uid!;
      isMe = false;
    } else {
      // Viewing myself
      profileUserId = currentUser!.uid;
      isMe = true;
      _checkAndCreateProfile();
    }
  }

  // Ensure my profile exists in database
  Future<void> _checkAndCreateProfile() async {
    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(profileUserId);
    final doc = await userDocRef.get();

    if (!doc.exists && isMe) {
      try {
        final currentUser = FirebaseAuth.instance.currentUser!;
        await userDocRef.set({
          'uid': profileUserId,
          'name': currentUser.displayName ?? 'New User',
          'bio': '',
          'profilePictureUrl': currentUser.photoURL ?? '',
          'email': currentUser.email ?? '',
        });
      } catch (e) {
        print("Error creating profile: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(isMe ? 'My Profile' : 'Profile'),
          actions: [
            // Only show Settings/Logout if it is MY profile
            if (isMe) ...[
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ));
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
              ),
            ]
          ],
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(profileUserId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('User not found'));
            }

            // Get User Data
            Map<String, dynamic> userData =
                snapshot.data!.data() as Map<String, dynamic>;
            String name = userData['name'] ?? 'No Name';
            String bio = userData['bio'] ?? '';
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
                          // 1. Avatar
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

                          // 2. Name
                          Text(
                            name,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),

                          // 3. Bio
                          if (bio.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              bio,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: subtitleColor),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          const SizedBox(height: 24),

                          // 4. STATS ROW (Visible for EVERYONE now)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatColumn(
                                  "Followers",
                                  _followService
                                      .getFollowerCount(profileUserId)),
                              _buildStatColumn(
                                  "Following",
                                  _followService
                                      .getFollowingCount(profileUserId)),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // 5. BUTTONS (Different for Me vs Others)
                          if (isMe)
                            // "Edit Profile" for ME
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
                            )
                          else
                            // "Follow" + "Message" for OTHERS
                            Row(
                              children: [
                                // --- REAL-TIME FOLLOW BUTTON ---
                                Expanded(
                                  child: StreamBuilder<bool>(
                                    stream: _followService
                                        .isFollowingStream(profileUserId),
                                    builder: (context, followSnapshot) {
                                      // Default to false if loading
                                      bool isFollowing =
                                          followSnapshot.data ?? false;

                                      return ElevatedButton(
                                        onPressed: () {
                                          if (isFollowing) {
                                            _followService
                                                .unfollowUser(profileUserId);
                                          } else {
                                            _followService
                                                .followUser(profileUserId);
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isFollowing
                                              ? Colors.grey[800]
                                              : Theme.of(context).primaryColor,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: Text(isFollowing
                                            ? "Unfollow"
                                            : "Follow"),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChatScreen(
                                            recipientId: profileUserId,
                                            recipientName: name,
                                            recipientProfilePic: profilePic,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text("Message"),
                                  ),
                                ),
                              ],
                            ),

                          const Divider(height: 40),
                          Text(
                            isMe ? 'My Posts' : "$name's Posts",
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
                    .where('uid', isEqualTo: profileUserId)
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
                        child: Text('No posts yet.'),
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
                            postData['postId'] = post.id; // Inject ID

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
                            uid: profileUserId,
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

  // Helper widget for Stats
  Widget _buildStatColumn(String label, Stream<int> stream) {
    return StreamBuilder<int>(
      stream: stream,
      builder: (context, snapshot) {
        return Column(
          children: [
            Text(
              snapshot.hasData ? snapshot.data.toString() : "0",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: TextStyle(color: subtitleColor),
            ),
          ],
        );
      },
    );
  }
}
