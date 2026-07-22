export 'tflite_stub.dart'
    if (dart.library.io) 'tflite_mobile.dart'
    if (dart.library.html) 'tflite_web.dart';
