import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    // Request permission from the user
    await _firebaseMessaging.requestPermission();

    // Get the device's FCM token
    final String? fcmToken = await _firebaseMessaging.getToken();

    if (fcmToken != null) {
      // Save the token to the user's Firestore document
      await _saveTokenToDatabase(fcmToken);
    }

    // Listen for token refreshes and save them too
    _firebaseMessaging.onTokenRefresh.listen(_saveTokenToDatabase);
  }

  Future<void> _saveTokenToDatabase(String token) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final String userId = user.uid;

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'fcmTokens': FieldValue.arrayUnion([token]),
    });
  }
}
