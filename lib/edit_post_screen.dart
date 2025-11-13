import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditPostScreen extends StatefulWidget {
  final String postId;
  final String initialText;

  const EditPostScreen({
    super.key,
    required this.postId,
    required this.initialText,
  });

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  late TextEditingController _textController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
  }

  Future<void> _saveChanges() async {
    if (_textController.text.trim().isEmpty) {
      // We can decide if empty text is allowed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Post text cannot be empty'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Update the post text in Firestore
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .update({
        'postText': _textController.text.trim(),
      });

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to save changes: $e'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Post'),
        actions: [
          // Save Button
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isLoading ? null : _saveChanges,
            tooltip: 'Save Changes',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _textController,
                autofocus: true,
                maxLines: null, // Allows the field to expand
                expands: true,
                decoration: const InputDecoration(
                  hintText: "What's on your mind?",
                  border: InputBorder.none,
                  fillColor: Colors.transparent,
                ),
              ),
            ),
    );
  }
}
