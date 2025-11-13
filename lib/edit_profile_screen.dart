import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  File? _imageFile;
  XFile? _imageFileWeb;
  final ImagePicker _picker = ImagePicker();

  final cloudinary = CloudinaryPublic(
    'deel0p5c4',
    'yfc9ktwk',
    cache: false,
  );

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData['name']);
    _bioController = TextEditingController(text: widget.userData['bio']);
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (kIsWeb) {
          _imageFileWeb = pickedFile;
        } else {
          _imageFile = File(pickedFile.path);
        }
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null && _imageFileWeb == null) return null;

    try {
      final String filePath = kIsWeb ? _imageFileWeb!.path : _imageFile!.path;

      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(filePath,
            resourceType: CloudinaryResourceType.Image),
      );
      return response.secureUrl;
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl = widget.userData['profilePictureUrl'];

      if (_imageFile != null || _imageFileWeb != null) {
        imageUrl = await _uploadImage();
      }

      String uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': _nameController.text.trim(),
        'bio': _bioController.text.trim(),
        'profilePictureUrl': imageUrl ?? '',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Profile saved!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to save profile: $e'),
              backgroundColor: Colors.red),
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

  ImageProvider? _getImageProvider() {
    final String existingUrl = widget.userData['profilePictureUrl'] ?? '';

    if (_imageFileWeb != null) {
      return NetworkImage(_imageFileWeb!.path);
    }
    if (_imageFile != null) {
      return FileImage(_imageFile!);
    }
    if (existingUrl.isNotEmpty) {
      return NetworkImage(existingUrl);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isLoading ? null : _saveProfile,
            tooltip: 'Save',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _getImageProvider(),
                        child: _getImageProvider() == null
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                    ),
                    TextButton(
                      onPressed: _pickImage,
                      child: const Text('Change Profile Photo'),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) =>
                          value!.isEmpty ? 'Name cannot be empty' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _bioController,
                      decoration: const InputDecoration(labelText: 'Bio'),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
