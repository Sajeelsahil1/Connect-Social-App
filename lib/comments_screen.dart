import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:social_connect/theme.dart';

class CommentsScreen extends StatefulWidget {
  final String postId;
  const CommentsScreen({super.key, required this.postId});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _commentController = TextEditingController();
  final User currentUser = FirebaseAuth.instance.currentUser!;
  bool _isPosting = false;

  Future<void> _postComment() async {
    if (_commentController.text.trim().isEmpty) {
      return;
    }
    setState(() {
      _isPosting = true;
    });

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      final userData = userDoc.data() as Map<String, dynamic>;

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .add({
        'text': _commentController.text.trim(),
        'uid': currentUser.uid,
        'name': userData['name'] ?? 'User',
        'profilePic': userData['profilePictureUrl'] ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      });

      final postDoc = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .get();
      final postOwnerUid = postDoc.data()?['uid'];

      if (postOwnerUid != null && postOwnerUid != currentUser.uid) {
        await FirebaseFirestore.instance.collection('notifications').add({
          'type': 'comment',
          'senderUid': currentUser.uid,
          'senderName': userData['name'] ?? 'User',
          'recipientUid': postOwnerUid,
          'postId': widget.postId,
          'commentText': _commentController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
        });
      }

      _commentController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to post comment: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      // --- FIX: ADD MOUNTED CHECK (This is line 80) ---
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(widget.postId)
                  .collection('comments')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No comments yet.'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final comment = snapshot.data!.docs[index];
                    final data = comment.data() as Map<String, dynamic>;
                    final String profilePic = data['profilePic'] ?? '';
                    final Timestamp timestamp =
                        data['timestamp'] ?? Timestamp.now();

                    return ListTile(
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundImage: profilePic.isNotEmpty
                            ? NetworkImage(profilePic)
                            : null,
                        child: profilePic.isEmpty
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: [
                            TextSpan(
                              text: data['name'] ?? 'User',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(text: ' '),
                            TextSpan(text: data['text'] ?? ''),
                          ],
                        ),
                      ),
                      subtitle: Text(
                        DateFormat('MMM d, yyyy - hh:mm a')
                            .format(timestamp.toDate()),
                        style:
                            const TextStyle(color: subtitleColor, fontSize: 12),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: InputBorder.none,
                      fillColor: Colors.transparent,
                    ),
                    maxLines: 1,
                  ),
                ),
                IconButton(
                  icon: _isPosting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.send, color: primaryColor),
                  onPressed: _isPosting ? null : _postComment,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
