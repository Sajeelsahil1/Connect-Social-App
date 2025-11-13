import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- 1. Get or Create Chat Room ---
  Future<String> getChatRoomId(String recipientId) async {
    final String currentUserId = _auth.currentUser!.uid;
    List<String> ids = [currentUserId, recipientId];
    ids.sort(); // Sort to ensure the chat room ID is always the same
    String chatRoomId = ids.join('_');

    // Create chat room document if it doesn't exist
    await _firestore.collection('chat_rooms').doc(chatRoomId).set({
      'users': [currentUserId, recipientId],
      'lastMessage': '',
      'lastTimestamp': Timestamp.now(),
    }, SetOptions(merge: true));

    return chatRoomId;
  }

  // --- 2. Send Message ---
  Future<void> sendMessage(
      String recipientId, String chatRoomId, String messageText) async {
    final String currentUserId = _auth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();

    // Create the message
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add({
      'senderId': currentUserId,
      'recipientId': recipientId,
      'message': messageText,
      'type': 'text',
      'timestamp': timestamp,
    });

    // Update the last message in the chat room
    await _firestore.collection('chat_rooms').doc(chatRoomId).update({
      'lastMessage': messageText,
      'lastTimestamp': timestamp,
    });
  }

  // --- 3. Get Messages Stream ---
  Stream<QuerySnapshot> getMessages(String chatRoomId) {
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // --- 4. Get Chat List Stream ---
  Stream<QuerySnapshot> getChatList() {
    final String currentUserId = _auth.currentUser!.uid;
    return _firestore
        .collection('chat_rooms')
        .where('users', arrayContains: currentUserId)
        .orderBy('lastTimestamp', descending: true)
        .snapshots();
  }

  // --- 5. Upload Media to Cloudinary ---
  Future<Map<String, String>?> uploadMedia(XFile file, bool isVideo) async {
    // !! IMPORTANT: FILL IN YOUR CLOUDINARY DETAILS !!
    final cloudinary = CloudinaryPublic(
      'deel0p5c4',
      'yfc9ktwk',
      cache: false,
    );

    try {
      final String filePath = file.path;
      final CloudinaryResourceType resourceType =
          isVideo ? CloudinaryResourceType.Video : CloudinaryResourceType.Image;

      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(filePath, resourceType: resourceType),
      );

      return {
        'url': response.secureUrl,
        'type': isVideo ? 'video' : 'image',
      };
    } catch (e) {
      return null;
    }
  }

  // --- 6. Send Media Message ---
  Future<void> sendMediaMessage(
      String recipientId, String chatRoomId, XFile file, bool isVideo) async {
    final uploadResult = await uploadMedia(file, isVideo);
    if (uploadResult == null) {
      // Handle upload failure
      return;
    }

    final String currentUserId = _auth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();
    final String messageType = isVideo ? 'video' : 'image';
    final String lastMessage = isVideo ? 'Sent a video' : 'Sent an image';

    // Create the media message
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add({
      'senderId': currentUserId,
      'recipientId': recipientId,
      'message': uploadResult['url'], // Store the URL
      'type': messageType,
      'timestamp': timestamp,
    });

    // Update the last message
    await _firestore.collection('chat_rooms').doc(chatRoomId).update({
      'lastMessage': lastMessage,
      'lastTimestamp': timestamp,
    });
  }
}
