import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:farmai/core/constants/app_constants.dart';

void main() {
  final supabaseUrl = Platform.environment['SUPABASE_URL'];
  final anonKey = Platform.environment['SUPABASE_ANON_KEY'];

  group('Supabase Backend & RLS Security Tests', () {
    setUpAll(() async {
      // If environment variables are present, initialize Supabase client pointing to the target DB
      if (supabaseUrl != null && anonKey != null) {
        try {
          await Supabase.initialize(
            url: supabaseUrl,
            anonKey: anonKey,
          );
        } catch (_) {
          // Already initialized
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
