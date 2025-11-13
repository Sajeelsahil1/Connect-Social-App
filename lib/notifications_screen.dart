import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:social_connect/theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  // --- 1. FUNCTION TO MARK ALL AS READ ---
  Future<void> _markAllAsRead(String currentUserId) async {
    final writeBatch = FirebaseFirestore.instance.batch();
    final querySnapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('recipientUid', isEqualTo: currentUserId)
        .where('read', isEqualTo: false)
        .get();

    for (var doc in querySnapshot.docs) {
      writeBatch.update(doc.reference, {'read': true});
    }
    await writeBatch.commit();
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          // --- 2. ADD "MARK ALL READ" BUTTON ---
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: () => _markAllAsRead(currentUserId),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('recipientUid', isEqualTo: currentUserId)
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
            return const Center(child: Text('You have no notifications.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final String type = data['type'] ?? '';
              final String senderName = data['senderName'] ?? 'Someone';
              final Timestamp timestamp = data['timestamp'] ?? Timestamp.now();
              final bool isUnread = data['read'] == false; // Check if unread

              String title;
              String subtitle;
              IconData icon;

              if (type == 'like') {
                title = '$senderName liked your post';
                subtitle = data['postText'] ?? '';
                icon = Icons.favorite;
              } else if (type == 'comment') {
                title = '$senderName commented on your post';
                subtitle = data['commentText'] ?? '';
                icon = Icons.comment;
              } else {
                title = 'New notification';
                subtitle = '...';
                icon = Icons.notifications;
              }

              return Container(
                // 3. Highlight unread notifications
                color: isUnread
                    ? primaryColor.withOpacity(0.1)
                    : Colors.transparent,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: type == 'like'
                        ? Colors.red[100]
                        : accentColor.withOpacity(0.3),
                    child: Icon(icon,
                        color: type == 'like' ? Colors.red : accentColor),
                  ),
                  title: Text(title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(subtitle,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Text(
                    DateFormat('MMM d').format(timestamp.toDate()),
                    style: const TextStyle(color: subtitleColor, fontSize: 12),
                  ),
                  onTap: () {
                    // 4. Mark individual notification as read on tap
                    if (isUnread) {
                      FirebaseFirestore.instance
                          .collection('notifications')
                          .doc(doc.id)
                          .update({'read': true});
                    }
                    // TODO: Navigate to the post
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
