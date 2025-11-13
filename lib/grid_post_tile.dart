import 'package:flutter/material.dart';
import 'package:social_connect/theme.dart';

class GridPostTile extends StatelessWidget {
  final Map<String, dynamic> postData;

  const GridPostTile({super.key, required this.postData});

  @override
  Widget build(BuildContext context) {
    final String? fileUrl = postData['fileUrl'];
    final String? fileType = postData['fileType'];

    return Container(
      decoration: BoxDecoration(
        color: cardColor, // A fallback color
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: (fileUrl != null && fileType == 'image')
            ? Image.network(
                fileUrl,
                fit: BoxFit.cover,
                // Loading builder for a smoother feel
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2));
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.broken_image, color: subtitleColor);
                },
              )
            : (fileType == 'video')
                ? const Stack(
                    // Show a video icon
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.play_circle_fill,
                          color: Colors.white70, size: 40),
                    ],
                  )
                : const Icon(Icons.article,
                    color: subtitleColor), // For text-only posts
      ),
    );
  }
}
