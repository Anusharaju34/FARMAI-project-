import 'dart:typed_data';

class TfliteClassifier {
  static Future<TfliteClassifier> create() async {
    return TfliteClassifier();
  }

  Future<Map<String, dynamic>> classifyImage(
      Uint8List imageBytes, String filename) async {
    return {
      'label': 'Invalid / Non-leaf',
      'confidence': 0.0,
    };
  }
}
