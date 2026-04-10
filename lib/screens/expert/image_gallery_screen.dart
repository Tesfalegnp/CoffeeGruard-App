// image_gallery_screen.dart

import 'package:flutter/material.dart';

class ImageGalleryScreen extends StatelessWidget {
  const ImageGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Gallery"),
        backgroundColor: Colors.green,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 20, // replace with real data
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Image Details"),
                  content: const Text("Disease: Rust\nSeverity: High"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close"),
                    ),
                    TextButton(
                      onPressed: () {
                        // DELETE LOGIC HERE
                      },
                      child: const Text("Delete"),
                    ),
                  ],
                ),
              );
            },
            child: Container(
              color: Colors.grey.shade300,
              child: const Icon(Icons.image),
            ),
          );
        },
      ),
    );
  }
}