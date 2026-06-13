import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Initialize the test widgets binding first to prevent WidgetsFlutterBinding conflict errors
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock initial values for SharedPreferences to avoid MissingPluginException in unit/widget tests
  SharedPreferences.setMockInitialValues({});

  // Supabase initialization will be handled lazily within the test zone context.

  await testMain();
}
