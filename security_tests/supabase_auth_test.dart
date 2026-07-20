import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Simple Supabase auth check using REST
// Set SUPABASE_URL and SERVICE_ROLE_KEY in environment when running tests

Future<void> main() async {
  final supabaseUrl = Uri.parse(Platform.environment['SUPABASE_URL'] ?? 'https://example.supabase.co');
  final anon = Platform.environment['SUPABASE_ANON_KEY'] ?? 'test-anon-key';

  final res = await http.get(
    supabaseUrl.replace(path: '/auth/v1/user'),
    headers: {'apikey': anon},
  );

  print('Auth endpoint status: \\${res.statusCode}');
}
