import 'dart:io';
import 'package:flutter/material.dart';
import '../core/utils/image_utils.dart';

class ImagePickerWidget extends StatefulWidget {

  final Function(File image) onImageSelected;

  const ImagePickerWidget({super.key, required this.onImageSelected});

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {

  File? selectedImage;

  Future<void> _pickCamera() async {

    final image = await ImageUtils.pickFromCamera();

    if (image != null) {
      setState(() {
        selectedImage = image;
      });

      widget.onImageSelected(image);
    }
  }

  Future<void> _pickGallery() async {

    final image = await ImageUtils.pickFromGallery();

    if (image != null) {
      setState(() {
        selectedImage = image;
      });

      widget.onImageSelected(image);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [

        selectedImage != null
            ? Image.file(selectedImage!, height: 200)
            : const Icon(Icons.image, size: 150),

        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text("Camera"),
              onPressed: _pickCamera,
            ),

            const SizedBox(width: 20),

            ElevatedButton.icon(
              icon: const Icon(Icons.photo),
              label: const Text("Gallery"),
              onPressed: _pickGallery,
            ),

          ],
        ),
      ],
    );
  }
}