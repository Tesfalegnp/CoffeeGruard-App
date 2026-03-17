import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageUtils {

  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickFromCamera() async {

    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (image == null) return null;

    return File(image.path);
  }

  static Future<File?> pickFromGallery() async {

    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) return null;

    return File(image.path);
  }

  static Future<String> saveImageLocally(File imageFile) async {

    final directory = await getApplicationDocumentsDirectory();

    final String newPath =
        "${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";

    final File newImage = await imageFile.copy(newPath);

    return newImage.path;
  }
}