import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_connect/comments_screen.dart';
import 'package:social_connect/edit_post_screen.dart';
import 'package:social_connect/theme.dart';
import 'package:video_player/video_player.dart';
import 'package:intl/intl.dart';

class PostCard extends StatefulWidget {
  final String postId;
  final String uid; // This is the post owner's UID
  final String name;
  final String profilePic;
  final String postText;
  final Timestamp timestamp;
  final List likes;
  final String? fileUrl;
  final String? fileType;
  final VoidCallback onProfileTap;

  const PostCard({
    Key? key,
    required this.postId,
    required this.uid,
    required this.name,
    required this.profilePic,
    required this.postText,
    required this.timestamp,
    required this.likes,
    this.fileUrl,
    this.fileType,
    required this.onProfileTap,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isLiked = false;
  bool _showLikeAnimation = false;
  String _likerName = 'Someone';

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
    _getLikerName();

    if (widget.fileType == 'video' && widget.fileUrl != null) {
      _videoController =
          VideoPlayerController.networkUrl(Uri.parse(widget.fileUrl!))
            ..initialize().then((_) {
              // --- FIX: ADD MOUNTED CHECK ---
              if (mounted) {
                setState(() {
                  _isVideoInitialized = true;
                });
              }
              _videoController?.setLooping(true);
              _videoController?.setVolume(0);
              _videoController?.play();
            });
    }
  }

  void _checkIfLiked() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _isLiked = widget.likes.contains(user.uid);
      });
    }
  }

  Future<void> _getLikerName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        // --- FIX: ADD MOUNTED CHECK ---
        if (mounted) {
          setState(() {
            _likerName = userDoc.data()?['name'] ?? 'Someone';
          });
        }
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> _toggleLike() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final String currentUserId = user.uid;

    bool newLikedState = !_isLiked;

    setState(() {
      _isLiked = newLikedState;
      if (newLikedState) {
        widget.likes.add(currentUserId);
        _showLikeAnimation = true;
      } else {
        widget.likes.remove(currentUserId);
      }
    });

    if (_showLikeAnimation) {
      await Future.delayed(const Duration(milliseconds: 600));
      // --- FIX: ADD MOUNTED CHECK ---
      if (mounted) {
        setState(() {
          _showLikeAnimation = false;
        });
      }
    }

    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .update({
        'likes': newLikedState
            ? FieldValue.arrayUnion([currentUserId])
            : FieldValue.arrayRemove([currentUserId])
      });

      if (newLikedState && widget.uid != currentUserId) {
        await FirebaseFirestore.instance.collection('notifications').add({
          'type': 'like',
          'senderUid': currentUserId,
          'senderName': _likerName,
          'recipientUid': widget.uid,
          'postId': widget.postId,
          'postText':
              widget.postText.isNotEmpty ? widget.postText : 'your media',
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
        });
      }
    } catch (e) {
      // --- FIX: ADD MOUNTED CHECK (This is line 142) ---
      if (mounted) {
        setState(() {
          _isLiked = !newLikedState;
          if (newLikedState) {
            widget.likes.remove(currentUserId);
          } else {
            widget.likes.add(currentUserId);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final postTime = timestamp.toDate();
    final difference = now.difference(postTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(postTime);
    }
  }

  Widget _buildMediaWidget() {
    Widget? media;

    if (widget.fileType == 'image' && widget.fileUrl != null) {
      media = Image.network(widget.fileUrl!, fit: BoxFit.cover);
    } else if (widget.fileType == 'video' &&
        _videoController != null &&
        _isVideoInitialized) {
      media = GestureDetector(
        onTap: () {
          if (_videoController!.value.volume == 0) {
            _videoController?.setVolume(1.0);
          } else {
            _videoController?.setVolume(0);
          }
        },
        child: AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        ),
      );
    }

    if (media == null) return const SizedBox.shrink();

    return GestureDetector(
      onDoubleTap: _toggleLike,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(12), child: media),
          ),
          AnimatedScale(
            scale: _showLikeAnimation ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.elasticOut,
            child: Icon(Icons.favorite,
                color: Colors.white.withOpacity(0.8), size: 100),
          )
        ],
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: accentColor),
              title: const Text('Edit Post'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => EditPostScreen(
                    postId: widget.postId,
                    initialText: widget.postText,
                  ),
                ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.redAccent),
              title: const Text('Delete Post',
                  style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post?'),
        content: const Text(
            'Are you sure you want to delete this post? This cannot be undone.'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child:
                const Text('Delete', style: TextStyle(color: Colors.redAccent)),
            onPressed: () {
              Navigator.pop(context);
              _deletePost();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deletePost() async {
    try {
      final commentsQuery = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .get();

      final WriteBatch batch = FirebaseFirestore.instance.batch();
      for (var doc in commentsQuery.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .delete();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to delete post: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const SizedBox.shrink();
    }

    final String currentUserId = user.uid;
    final bool isMyPost = widget.uid == currentUserId;

    _checkIfLiked();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: widget.onProfileTap,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: widget.profilePic.isNotEmpty
                        ? NetworkImage(widget.profilePic)
                        : null,
                    child: widget.profilePic.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      widget.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(),
                  if (isMyPost)
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.grey),
                      onPressed: () => _showOptions(context),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (widget.postText.isNotEmpty)
              Text(widget.postText, style: const TextStyle(fontSize: 16)),
            _buildMediaWidget(),
            const SizedBox(height: 10),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.red : null,
                  ),
                  onPressed: _toggleLike,
                ),
                Flexible(
                  child: Text(
                    '${widget.likes.length} ${widget.likes.length == 1 ? 'like' : 'likes'}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          CommentsScreen(postId: widget.postId),
                    ));
                  },
                ),
                StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .doc(widget.postId)
                        .collection('comments')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text('${snapshot.data!.docs.length} comments');
                      }
                      return const Text('0 comments');
                    }),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 12.0),
              child: Text(
                _formatTimestamp(widget.timestamp),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
