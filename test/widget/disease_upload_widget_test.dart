import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmai/services/supabase_service.dart';
import '../mocks/mock_storage_adapter.dart';
import '../mocks/mock_providers.dart';
import '../helpers/asset_helper.dart';
import 'package:farmai/screens/disease/disease_detection_screen.dart';

void main() {
  testWidgets('Disease detection screen uploads image and shows result',
      (WidgetTester tester) async {
    // prepare test image
    final imagePath = await writeTestPngToTemp();

    final mock = MockStorageAdapter();
    SupabaseService.storageAdapter = mock;

    await tester.pumpWidget(
      ProviderScope(
        overrides: getTestProviderOverrides(),
        child: MaterialApp(
          home: DiseaseDetectionScreen(
            testImagePath: imagePath,
            testDisableSave: true,
          ),
        ),
      ),
    );

    // Use bounded pumps instead of pumpAndSettle to avoid animation timeout
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 1));

    // The analyze button should now be visible since testImagePath prefilled
    final analyze = find.text('Analyze Disease');
    expect(analyze, findsOneWidget);

    await tester.tap(analyze);
    await tester.pump(const Duration(milliseconds: 300));
    // allow async operations (mock upload + delay)
    await tester.pump(const Duration(seconds: 3));

    // verify mock upload was called
    expect(mock.calls.length, 1);

    // Result card should appear with disease name
    expect(find.textContaining('Leaf Blight'), findsOneWidget);
  });
}
