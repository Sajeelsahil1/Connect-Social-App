import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// 'theme.dart' import is no longer needed here
import 'package:video_player/video_player.dart';
import 'package:social_connect/theme.dart'; // <-- We need this for the colors

class MessageBubble extends StatefulWidget {
  final String message;
  final String type;
  final bool isMe;
  final Timestamp timestamp;

  const MessageBubble({
    super.key,
    required this.message,
    required this.type,
    required this.isMe,
    required this.timestamp,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.type == 'video') {
      _videoController =
          VideoPlayerController.networkUrl(Uri.parse(widget.message))
            ..initialize().then((_) {
              setState(() {
                _isVideoInitialized = true;
              });
              _videoController?.setLooping(false);
              _videoController?.setVolume(1.0);
            });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Widget _buildMediaWidget() {
    if (widget.type == 'image') {
      return Image.network(widget.message);
    } else if (widget.type == 'video' &&
        _videoController != null &&
        _isVideoInitialized) {
      return AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_videoController!),
            IconButton(
              icon: Icon(
                _videoController!.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
                color: Colors.white,
                size: 40,
              ),
              onPressed: () {
                setState(() {
                  _videoController!.value.isPlaying
                      ? _videoController!.pause()
                      : _videoController!.play();
                });
              },
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    // --- START OF FIX ---
    // Determine styles locally based on theme brightness and 'isMe'
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Color sentColor = primaryColor;
    final Color receivedColor =
        isDarkMode ? cardColor : const Color(0xFFE0E0E0);

    final TextStyle sentTextStyle = const TextStyle(color: Colors.white);
    final TextStyle receivedTextStyle = isDarkMode
        ? const TextStyle(color: Colors.white)
        : const TextStyle(color: Colors.black);

    final decoration = BoxDecoration(
      color: widget.isMe ? sentColor : receivedColor,
      borderRadius: const BorderRadius.all(Radius.circular(18)),
    );
    final textStyle = widget.isMe ? sentTextStyle : receivedTextStyle;
    // --- END OF FIX ---

    return Align(
      alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        decoration: decoration,
        padding: widget.type == 'text'
            ? const EdgeInsets.symmetric(vertical: 10, horizontal: 16)
            : const EdgeInsets.all(3),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: widget.type == 'text'
            ? Text(widget.message, style: textStyle)
            : ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: _buildMediaWidget(),
              ),
      ),
    );
  }
}
