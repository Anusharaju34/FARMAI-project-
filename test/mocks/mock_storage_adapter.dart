import 'dart:io';
import 'package:farmai/services/storage_adapter.dart';

class MockStorageAdapter implements StorageAdapter {
  List<Map<String, dynamic>> calls = [];

  @override
  Future<String> uploadImage({required File file, required String bucket, required String path}) async {
    calls.add({'filePath': file.path, 'bucket': bucket, 'path': path});
    // Simulate an upload delay
    await Future.delayed(Duration(milliseconds: 10));
    return 'https://example.supabase.co/storage/v1/object/public/$bucket/$path';
  }
}
