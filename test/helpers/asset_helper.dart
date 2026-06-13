import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as p;

/// Reads the base64 asset from `test_assets/images/white1.base64`
/// and writes it to a temp file, returning the path.
Future<String> writeTestPngToTemp() async {
  final base64Str = File('test_assets/images/white1.base64').readAsStringSync();
  final bytes = base64Decode(base64Str);
  final dir = Directory.systemTemp.createTempSync('farmai_test_');
  final file = File(p.join(dir.path, 'white1.png'));
  file.writeAsBytesSync(bytes);
  return file.path;
}
