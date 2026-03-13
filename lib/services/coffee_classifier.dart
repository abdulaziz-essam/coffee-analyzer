import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class CoffeeClassifier {
  Interpreter? _interpreter;
  
  CoffeeClassifier() {
    _interpreter = Interpreter.fromBuffer(await rootBundle.load('assets/coffee_model.tflite'));
  }

  loadModel() async {
    _interpreter = Interpreter.fromAsset('assets/models/coffee_model.tflite');
  }
}