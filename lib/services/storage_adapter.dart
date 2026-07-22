import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class StorageAdapter {
  Future<String> uploadImage({
    required XFile file,
    required String bucket,
    required String path,
  });
}

class SupabaseStorageAdapter implements StorageAdapter {
  SupabaseStorageAdapter({
    SupabaseClient? client,
  }) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<String> uploadImage({
    required XFile file,
    required String bucket,
    required String path,
  }) async {
    try {
      final bytes = await file.readAsBytes();

      await _client.storage.from(bucket).uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(
          upsert: true,
          contentType: _getContentType(file.name),
        ),
      );

      return _client.storage.from(bucket).getPublicUrl(path);
    } on StorageException catch (error) {
      throw Exception(
        'Supabase image upload failed: ${error.message}',
      );
    } catch (error) {
      throw Exception(
        'Image upload failed: $error',
      );
    }
  }

  String _getContentType(String fileName) {
    final name = fileName.toLowerCase();

    if (name.endsWith('.png')) {
      return 'image/png';
    }

    if (name.endsWith('.webp')) {
      return 'image/webp';
    }

    if (name.endsWith('.gif')) {
      return 'image/gif';
    }

    return 'image/jpeg';
  }
}