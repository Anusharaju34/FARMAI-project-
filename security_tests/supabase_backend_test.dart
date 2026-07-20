// ignore_for_file: avoid_print, invalid_use_of_visible_for_testing_member
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:farmai/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  String? supabaseUrl = Platform.environment['SUPABASE_URL'];
  String? anonKey = Platform.environment['SUPABASE_ANON_KEY'];

  // Load from .env file if environment variables are not set
  if (supabaseUrl == null || anonKey == null) {
    try {
      final file = File('.env');
      if (file.existsSync()) {
        for (var line in file.readAsLinesSync()) {
          line = line.trim();
          if (line.isEmpty || line.startsWith('#')) continue;
          final idx = line.indexOf('=');
          if (idx != -1) {
            final key = line.substring(0, idx).trim();
            final val = line.substring(idx + 1).trim();
            if (key == 'SUPABASE_URL') {
              supabaseUrl = val;
            } else if (key == 'SUPABASE_ANON_KEY') {
              anonKey = val;
            }
          }
        }
      }
    } catch (_) {}
  }

  group('Supabase Backend & RLS Security Tests', () {
    setUpAll(() async {
      // Mock native shared_preferences storage before initialization
      SharedPreferences.setMockInitialValues({});
      
      // If environment variables are present, initialize Supabase client pointing to the target DB
      if (supabaseUrl != null && anonKey != null) {
        try {
          // Verify network/host lookup first to avoid native platform storage crashing and SocketException failing tests ungracefully
          final host = Uri.parse(supabaseUrl!).host;
          await InternetAddress.lookup(host);
          
          await Supabase.initialize(
            url: supabaseUrl!,
            anonKey: anonKey!,
            authOptions: FlutterAuthClientOptions(
              localStorage: const EmptyLocalStorage(),
            ),
          );
        } catch (e) {
          print('Skipping live Supabase checks: Unable to connect/resolve host $supabaseUrl (Error: $e)');
          // Set to null to skip tests gracefully
          supabaseUrl = null;
          anonKey = null;
        }
      }
    });

    test('Anonymous write access is blocked by RLS policies', () async {
      if (supabaseUrl == null || anonKey == null) {
        print('Skipping live Supabase REST checks (env vars SUPABASE_URL / SUPABASE_ANON_KEY not set).');
        return;
      }

      final client = Supabase.instance.client;

      // Attempt anonymous insert to users table - should fail with PostgrestException (401 Unauthorized or 403 Forbidden)
      expect(
        () async => await client.from(AppConstants.usersTable).insert({
          'id': '00000000-0000-0000-0000-000000000000',
          'email': 'hacker@malicious.com',
          'full_name': 'Hacker',
        }),
        throwsA(isA<PostgrestException>()),
      );

      // Attempt anonymous insert to irrigation records - should fail
      expect(
        () async => await client.from(AppConstants.irrigationRecordsTable).insert({
          'user_id': '00000000-0000-0000-0000-000000000000',
          'crop_type': 'Rice',
          'soil_type': 'Clay',
          'water_required': 12.5,
        }),
        throwsA(isA<PostgrestException>()),
      );

      // Attempt anonymous insert to forum posts - should fail
      expect(
        () async => await client.from(AppConstants.forumPostsTable).insert({
          'user_id': '00000000-0000-0000-0000-000000000000',
          'title': 'Hack attempt',
          'content': 'Attempt to post anonymously',
        }),
        throwsA(isA<PostgrestException>()),
      );
    });

    test('Anonymous read access constraints', () async {
      if (supabaseUrl == null || anonKey == null) {
        return;
      }

      final client = Supabase.instance.client;

      // Attempt anonymous read from private tables (like notifications or user profiles)
      // RLS should hide records (returning empty list) or throw a permission error
      try {
        final users = await client.from(AppConstants.usersTable).select();
        expect(users, isEmpty, reason: 'Anonymous user should see 0 profile records');
      } catch (e) {
        expect(e, isA<PostgrestException>());
      }

      try {
        final notifications = await client.from(AppConstants.notificationsTable).select();
        expect(notifications, isEmpty, reason: 'Anonymous user should see 0 notifications');
      } catch (e) {
        expect(e, isA<PostgrestException>());
      }
    });

    test('Storage bucket upload restrictions', () async {
      if (supabaseUrl == null || anonKey == null) {
        return;
      }

      final client = Supabase.instance.client;

      // Attempt upload to crop-images bucket without authentication
      final dummyFile = File('temp_test.png');
      await dummyFile.writeAsBytes([0, 1, 2, 3]);

      expect(
        () async => await client.storage
            .from(AppConstants.cropImagesBucket)
            .upload('anonymous_hack.png', dummyFile),
        throwsA(isA<StorageException>()),
      );

      // Clean up temp file
      if (await dummyFile.exists()) {
        await dummyFile.delete();
      }
    });
  });
}
