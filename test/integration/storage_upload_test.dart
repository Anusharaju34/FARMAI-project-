import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:farmai/services/supabase_service.dart';
import '../helpers/asset_helper.dart';
import '../mocks/mock_storage_adapter.dart';

void main() {
  test('SupabaseService.uploadImage uses storage adapter and returns public url', () async {
    final mock = MockStorageAdapter();
    // Inject mock
    SupabaseService.storageAdapter = mock;

    final path = await writeTestPngToTemp();
    final file = XFile(path);

    final url = await SupabaseService.uploadImage(file: file, bucket: 'test-bucket', path: 'uploads/white1.png');

    expect(url, contains('https://example.supabase.co'));
    expect(mock.calls.length, 1);
    final call = mock.calls.first;
    expect(call['filePath'], file.path);
    expect(call['bucket'], 'test-bucket');
    expect(call['path'], 'uploads/white1.png');
  });
}
