import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class CoffeeClassifier {
  Interpreter? _interpreter;
  List<String> _labels = [];

  // Load labels from file
  Future<void> loadLabels() async {
    try {
      final labelsData = await rootBundle.loadString('assets/models/labels.txt');
      _labels = labelsData.split('\n').where((label) => label.isNotEmpty).toList();
      print('Loaded ${_labels.length} labels: $_labels');
    } catch (e) {
      print('Error loading labels: $e');
      // Fallback labels from your labels.txt
      _labels = ['Dark', 'Green', 'Light', 'Medium'];
    }
  }

  // Load the model when the app starts
  Future<void> loadModel() async {
    try {
      // Load labels first
      await loadLabels();

      // Then load model
      _interpreter = await Interpreter.fromAsset('assets/models/coffee_model.tflite');
      print('Model loaded successfully');
    } catch (e) {
      print('Error loading model: $e');
      rethrow;
    }
  }

  // Main classification method
  Future<Map<String, dynamic>> classifyImage(File imageFile) async {
    if (_interpreter == null) {
      throw Exception('Model not loaded');
    }

    if (_labels.isEmpty) {
      throw Exception('Labels not loaded');
    }

    try {
      // Step 1: Preprocess the image
      var input = processImage(imageFile);

      // Step 2: Prepare output buffer (size matches number of labels)
      var output = List.filled(1 * _labels.length, 0.0).reshape([1, _labels.length]);

      // Step 3: Run inference
      _interpreter!.run(input, output);

      // Step 4: Process results
      return _processOutput(output);

    } catch (e) {
      throw Exception('Classification failed: $e');
    }
  }

  // Fixed image processing with proper resizing
  List processImage(File imageFile) {
    // Decode image
    img.Image? image = img.decodeImage(imageFile.readAsBytesSync());
    if (image == null) {
      throw Exception('Could not decode image');
    }

    // CRITICAL: Resize to model's expected input size (224x224)
    img.Image resizedImage = img.copyResize(image, width: 224, height: 224);

    // Convert to Float32List normalized to [0, 1]
    var convertedBytes = Float32List(1 * 224 * 224 * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (var i = 0; i < 224; i++) {
      for (var j = 0; j < 224; j++) {
        var pixel = resizedImage.getPixel(j, i);
        buffer[pixelIndex++] = pixel.r / 255.0;
        buffer[pixelIndex++] = pixel.g / 255.0;
        buffer[pixelIndex++] = pixel.b / 255.0;
      }
    }

    // Reshape to [1, 224, 224, 3]
    return convertedBytes.reshape([1, 224, 224, 3]);
  }

  // Process model output
  Map<String, dynamic> _processOutput(List output) {
    // Get probabilities from output
    List<double> probabilities = List<double>.from(output[0]);

    // Find the index with highest probability
    double maxProb = probabilities.reduce((a, b) => a > b ? a : b);
    int maxIndex = probabilities.indexOf(maxProb);

    // Get all results sorted by confidence
    List<Map<String, dynamic>> allResults = [];
    for (int i = 0; i < probabilities.length; i++) {
      allResults.add({
        'label': _labels[i],
        'confidence': probabilities[i],
      });
    }
    allResults.sort((a, b) => b['confidence'].compareTo(a['confidence']));

    return {
      'label': _labels[maxIndex],
      'confidence': maxProb,
      'allResults': allResults,
    };
  }

  // Cleanup method
  void dispose() {
    _interpreter?.close();
  }
}
