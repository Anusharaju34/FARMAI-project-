import 'dart:io';

abstract class StorageAdapter {
  Future<String> uploadImage(
      {required File file, required String bucket, required String path});
}

class SupabaseStorageAdapter implements StorageAdapter {
  @override
  Future<String> uploadImage(
      {required File file,
      required String bucket,
      required String path}) async {
    // Default implementation uses Supabase.instance.client. Kept here to avoid
    // circular imports; SupabaseService will call this adapter only when set.
    // Implement a direct call to Supabase.instance.client to perform the upload.
    // Note: importing supabase here would create circular dependency, so keep
    // implementation minimal and prefer SupabaseService._storageAdapter to be
    // replaced with a test double in tests.
    throw UnimplementedError(
        'Use SupabaseService.storageAdapter override in tests');
  }
}
