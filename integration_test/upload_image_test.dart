import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import '../test/helpers/asset_helper.dart';

void main() {
  test('Write base64 test image and validate PNG header', () async {
    final path = await writeTestPngToTemp();
    final file = File(path);
    expect(await file.exists(), true);
    final bytes = await file.readAsBytes();
    
    // PNG signature: 89 50 4E 47 0D 0A 1A 0A
    expect(bytes.length >= 8, true);
    expect(bytes[0], 0x89);
    expect(bytes[1], 0x50);
    expect(bytes[2], 0x4E);
    expect(bytes[3], 0x47);
    expect(bytes[4], 0x0D);
    expect(bytes[5], 0x0A);
    expect(bytes[6], 0x1A);
    expect(bytes[7], 0x0A);
  });
}
