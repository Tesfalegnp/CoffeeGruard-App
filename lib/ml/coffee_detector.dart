import 'dart:io';
import 'dart:typed_data';

import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class CoffeeDetector {

  Interpreter? verifyModel;
  Interpreter? rustModel;

  bool _loaded = false;

  Future<void> loadModels() async {

    if (_loaded) return;

    verifyModel = await Interpreter.fromAsset(
      "assets/models/coffee_leaf_verification.tflite",
    );

    rustModel = await Interpreter.fromAsset(
      "assets/models/coffee_rust_model.tflite",
    );

    _loaded = true;

    print("☕ CoffeeGuard ML Models Loaded");
  }

  Future<Map<String, dynamic>> detect(File imageFile) async {

    await loadModels();

    final input = await preprocessImage(imageFile);

    /// Stage 1 : Coffee leaf verification
    var verifyOutput = List.generate(1, (_) => List.filled(1, 0.0));
    verifyModel!.run(input, verifyOutput);

    double verifyProb = verifyOutput[0][0];

    if (verifyProb >= 0.5) {

      return {
        "success": false,
        "message": "❌ Not a Coffee Leaf",
        "confidence": (verifyProb * 100).toStringAsFixed(2)
      };

    }

    /// Stage 2 : Rust detection
    var rustOutput = List.generate(1, (_) => List.filled(1, 0.0));
    rustModel!.run(input, rustOutput);

    double rustProb = rustOutput[0][0];

    if (rustProb > 0.5) {

      return {
        "success": true,
        "disease": "Rust",
        "confidence": (rustProb * 100).toStringAsFixed(2)
      };

    } else {

      return {
        "success": true,
        "disease": "Healthy",
        "confidence": ((1 - rustProb) * 100).toStringAsFixed(2)
      };

    }

  }

  Future<List> preprocessImage(File imageFile) async {

    final imageBytes = await imageFile.readAsBytes();

    img.Image? image = img.decodeImage(imageBytes);

    image = img.copyResize(image!, width: 224, height: 224);

    var input = Float32List(224 * 224 * 3);

    int index = 0;

    for (int y = 0; y < 224; y++) {

      for (int x = 0; x < 224; x++) {

        final pixel = image.getPixel(x, y);

        input[index++] = (pixel.r / 127.5) - 1;
        input[index++] = (pixel.g / 127.5) - 1;
        input[index++] = (pixel.b / 127.5) - 1;

      }

    }

    return input.reshape([1, 224, 224, 3]);
  }
}