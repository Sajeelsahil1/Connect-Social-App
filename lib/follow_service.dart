import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FollowService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Follow a user
  Future<void> followUser(String targetUserId) async {
    final currentUserId = _auth.currentUser!.uid;

    // 1. Add targetUser to my 'following' collection
    await _db
        .collection('users')
        .doc(currentUserId)
        .collection('following')
        .doc(targetUserId)
        .set({'timestamp': FieldValue.serverTimestamp()});

    // 2. Add me to targetUser's 'followers' collection
    await _db
        .collection('users')
        .doc(targetUserId)
        .collection('followers')
        .doc(currentUserId)
        .set({'timestamp': FieldValue.serverTimestamp()});
  }

  // Unfollow a user
  Future<void> unfollowUser(String targetUserId) async {
    final currentUserId = _auth.currentUser!.uid;

    // 1. Remove targetUser from my 'following' collection
    await _db
        .collection('users')
        .doc(currentUserId)
        .collection('following')
        .doc(targetUserId)
        .delete();

    // 2. Remove me from targetUser's 'followers' collection
    await _db
        .collection('users')
        .doc(targetUserId)
        .collection('followers')
        .doc(currentUserId)
        .delete();
  }

  // --- NEW: REAL-TIME FOLLOW STATUS ---
  Stream<bool> isFollowingStream(String targetUserId) {
    final currentUserId = _auth.currentUser!.uid;
    return _db
        .collection('users')
        .doc(currentUserId)
        .collection('following')
        .doc(targetUserId)
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  // Get User's Follower Count (Real-time)
  Stream<int> getFollowerCount(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('followers')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Get User's Following Count (Real-time)
  Stream<int> getFollowingCount(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('following')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
