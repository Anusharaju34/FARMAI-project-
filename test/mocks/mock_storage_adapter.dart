import 'package:image_picker/image_picker.dart';
import 'package:farmai/services/storage_adapter.dart';

class MockStorageAdapter implements StorageAdapter {
  List<Map<String, dynamic>> calls = [];

  @override
  Future<String> uploadImage({required XFile file, required String bucket, required String path}) async {
    calls.add({'filePath': file.path, 'bucket': bucket, 'path': path});
    // Simulate an upload delay
    await Future.delayed(const Duration(milliseconds: 10));
    return 'https://example.supabase.co/storage/v1/object/public/$bucket/$path';
  }
}
