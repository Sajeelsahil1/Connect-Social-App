import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:social_connect/theme.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _textController = TextEditingController();
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedFile;
  bool _isVideo = false;

  final cloudinary = CloudinaryPublic(
    'deel0p5c4',
    'yfc9ktwk',
    cache: false,
  );

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedFile = pickedFile;
        _isVideo = false;
      });
    }
  }

  Future<void> _pickVideo() async {
    final XFile? pickedFile =
        await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedFile = pickedFile;
        _isVideo = true;
      });
    }
  }

  Future<Map<String, String>?> _uploadFile() async {
    if (_pickedFile == null) return null;

    try {
      final String filePath = _pickedFile!.path;
      final CloudinaryResourceType resourceType = _isVideo
          ? CloudinaryResourceType.Video
          : CloudinaryResourceType.Image;

      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(filePath, resourceType: resourceType),
      );

      return {
        'url': response.secureUrl,
        'type': _isVideo ? 'video' : 'image',
      };
    } catch (e) {
      return null;
    }
  }

  Future<void> _submitPost() async {
    if (_textController.text.trim().isEmpty && _pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Post cannot be empty!'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser!;
      String? fileUrl;
      String? fileType;

      if (_pickedFile != null) {
        final uploadResult = await _uploadFile();
        if (uploadResult != null) {
          fileUrl = uploadResult['url'];
          fileType = uploadResult['type'];
        }
      }

      await FirebaseFirestore.instance.collection('posts').add({
        'uid': user.uid,
        'postText': _textController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'likes': [],
        'fileUrl': fileUrl,
        'fileType': fileType,
      });

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to post: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildPreview() {
    if (_pickedFile == null) {
      return const SizedBox.shrink();
    }

    Widget preview;
    if (_isVideo) {
      preview = Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam, size: 40, color: primaryColor),
            const SizedBox(width: 10),
            Text('Video selected',
                style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      );
    } else {
      preview = kIsWeb
          ? Image.network(_pickedFile!.path, fit: BoxFit.cover)
          : Image.file(File(_pickedFile!.path), fit: BoxFit.cover);
    }

    return Stack(
      alignment: Alignment.topRight,
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(12), child: preview),
        IconButton(
          icon: const CircleAvatar(
            backgroundColor: Colors.black54,
            child: Icon(Icons.close, color: Colors.white, size: 18),
          ),
          onPressed: () {
            setState(() {
              _pickedFile = null;
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitPost,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Post'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: "What's on your mind?",
                        border: InputBorder.none,
                        fillColor: Colors.transparent,
                      ),
                      maxLines: 5,
                      autofocus: true,
                    ),
                    const SizedBox(height: 20),
                    _buildPreview(),
                  ],
                ),
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.photo_library, color: primaryColor),
                  onPressed: _pickImage,
                  tooltip: 'Pick Image',
                ),
                IconButton(
                  icon: const Icon(Icons.videocam, color: accentColor),
                  onPressed: _pickVideo,
                  tooltip: 'Pick Video',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
