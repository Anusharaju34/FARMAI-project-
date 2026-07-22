import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:farmai/services/storage_adapter.dart';
import '../models/models.dart';
import '../core/constants/app_constants.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;
  static SupabaseClient get _client => client;

  // Storage adapter is injected here to allow tests to mock storage behavior.
  static StorageAdapter _storageAdapter = SupabaseStorageAdapter();

  static set storageAdapter(StorageAdapter adapter) {
    _storageAdapter = adapter;
  }

  // ============================================================
  // AUTH
  // ============================================================

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
      },
    );

    if (response.user != null) {
      await _client.from(AppConstants.usersTable).insert({
        'id': response.user!.id,
        'email': email,
        'full_name': fullName,
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    return response;
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  static Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  static User? get currentUser => _client.auth.currentUser;

  static Stream<AuthState> get authStateStream =>
      _client.auth.onAuthStateChange;

  // ============================================================
  // USER PROFILE
  // ============================================================

  static Future<UserModel?> getUserProfile(String userId) async {
    final response = await _client
        .from(AppConstants.usersTable)
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return UserModel.fromJson(response);
  }

  static Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    await _client
        .from(AppConstants.usersTable)
        .update(data)
        .eq('id', userId);
  }

  // ============================================================
  // STORAGE
  // ============================================================

  static Future<String> uploadImage({
    required XFile file,
    required String bucket,
    required String path,
  }) async {
    return _storageAdapter.uploadImage(
      file: file,
      bucket: bucket,
      path: path,
    );
  }

  // ============================================================
  // DISEASE PREDICTIONS
  // ============================================================

  static Future<List<DiseasePrediction>> getDiseasePredictions(
    String userId,
  ) async {
    final response = await _client
        .from(AppConstants.diseasePredictionsTable)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => DiseasePrediction.fromJson(item))
        .toList();
  }

  static Future<void> saveDiseasePrediction(
    Map<String, dynamic> data,
  ) async {
    await _client
        .from(AppConstants.diseasePredictionsTable)
        .insert(data);
  }

  // ============================================================
  // PEST DETECTIONS
  // ============================================================

  static Future<List<PestDetection>> getPestDetections(
    String userId,
  ) async {
    final response = await _client
        .from(AppConstants.pestDetectionsTable)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => PestDetection.fromJson(item))
        .toList();
  }

  static Future<void> savePestDetection(
    Map<String, dynamic> data,
  ) async {
    await _client
        .from(AppConstants.pestDetectionsTable)
        .insert(data);
  }

  // ============================================================
  // MARKET PRICES
  // ============================================================

  static Future<List<MarketPrice>> getMarketPrices() async {
    final response = await _client
        .from(AppConstants.marketPredictionsTable)
        .select()
        .order('updated_at', ascending: false);

    return (response as List)
        .map((item) => MarketPrice.fromJson(item))
        .toList();
  }

  // ============================================================
  // FORUM POSTS
  // ============================================================

  static Future<List<ForumPost>> getForumPosts({
    String? search,
  }) async {
    final response = await _client
        .from(AppConstants.forumPostsTable)
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => ForumPost.fromJson(item))
        .toList();
  }

  static Future<void> createForumPost(
    Map<String, dynamic> data,
  ) async {
    await _client
        .from(AppConstants.forumPostsTable)
        .insert(data);
  }

  static Future<void> likePost(
    String postId,
    String userId,
  ) async {
    await _client.rpc(
      'toggle_post_like',
      params: {
        'post_id': postId,
        'user_id': userId,
      },
    );
  }

  // ============================================================
  // EXPERT QUERIES
  // ============================================================

  static Future<List<ExpertQuery>> getExpertQueries(
    String userId,
  ) async {
    final response = await _client
        .from(AppConstants.expertQueriesTable)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => ExpertQuery.fromJson(item))
        .toList();
  }

  static Future<void> submitExpertQuery(
    Map<String, dynamic> data,
  ) async {
    await _client
        .from(AppConstants.expertQueriesTable)
        .insert(data);
  }

  // ============================================================
  // NOTIFICATIONS
  // ============================================================

  static Future<List<AppNotification>> getNotifications(
    String userId,
  ) async {
    final response = await _client
        .from(AppConstants.notificationsTable)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => AppNotification.fromJson(item))
        .toList();
  }

  static Future<void> markNotificationRead(
    String notificationId,
  ) async {
    await _client
        .from(AppConstants.notificationsTable)
        .update({
          'is_read': true,
        })
        .eq('id', notificationId);
  }

  static RealtimeChannel subscribeToNotifications(
    String userId,
    Function(Map<String, dynamic>) onNotification,
  ) {
    return _client
        .channel('notifications:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: AppConstants.notificationsTable,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            onNotification(payload.newRecord);
          },
        )
        .subscribe();
  }

  // ============================================================
  // IRRIGATION
  // ============================================================

  static Future<void> saveIrrigationRecord(
    Map<String, dynamic> data,
  ) async {
    await _client
        .from(AppConstants.irrigationRecordsTable)
        .insert(data);
  }

  static Future<List<IrrigationRecord>> getIrrigationHistory(
    String userId,
  ) async {
    final response = await _client
        .from(AppConstants.irrigationRecordsTable)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(10);

    return (response as List)
        .map((item) => IrrigationRecord.fromJson(item))
        .toList();
  }
}