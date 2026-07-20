import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';
import '../services/weather_service.dart';

// ============================================================
// AUTH PROVIDER
// ============================================================

final authStateProvider = StreamProvider<AuthState>((ref) {
  return SupabaseService.authStateStream;
});

final currentUserProvider = Provider<User?>((ref) {
  return SupabaseService.currentUser;
});

final userProfileProvider =
    FutureProvider.family<UserModel?, String>((ref, userId) async {
  return SupabaseService.getUserProfile(userId);
});

// ============================================================
// AUTH NOTIFIER
// ============================================================

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  AuthNotifier() : super(const AsyncValue.data(null));

  Future<bool> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await SupabaseService.signIn(email: email, password: password);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String fullName) async {
    state = const AsyncValue.loading();
    try {
      await SupabaseService.signUp(
          email: email, password: password, fullName: fullName);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> signOut() async {
    await SupabaseService.signOut();
  }

  Future<bool> resetPassword(String email) async {
    try {
      await SupabaseService.resetPassword(email);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<void>>(
        (_) => AuthNotifier());

// ============================================================
// WEATHER PROVIDER
// ============================================================

final weatherProvider =
    FutureProvider.family<WeatherData?, String>((ref, location) async {
  return WeatherService.getCurrentWeather(location);
});

// ============================================================
// DISEASE PROVIDER
// ============================================================

final diseasePredictionsProvider =
    FutureProvider.family<List<DiseasePrediction>, String>((ref, userId) async {
  return SupabaseService.getDiseasePredictions(userId);
});

// ============================================================
// PEST PROVIDER
// ============================================================

final pestDetectionsProvider =
    FutureProvider.family<List<PestDetection>, String>((ref, userId) async {
  return SupabaseService.getPestDetections(userId);
});

// ============================================================
// MARKET PROVIDER
// ============================================================

final marketPricesProvider = FutureProvider<List<MarketPrice>>((ref) async {
  return SupabaseService.getMarketPrices();
});

// ============================================================
// FORUM PROVIDER
// ============================================================

class ForumPostsNotifier extends StateNotifier<AsyncValue<List<ForumPost>>> {
  ForumPostsNotifier() : super(const AsyncValue.loading()) {
    loadPosts();
  }

  Future<void> loadPosts({String? search}) async {
    state = const AsyncValue.loading();
    try {
      final posts = await SupabaseService.getForumPosts(search: search);
      state = AsyncValue.data(posts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createPost(Map<String, dynamic> data) async {
    await SupabaseService.createForumPost(data);
    await loadPosts();
  }
}

final forumPostsProvider =
    StateNotifierProvider<ForumPostsNotifier, AsyncValue<List<ForumPost>>>(
        (_) => ForumPostsNotifier());

// ============================================================
// EXPERT QUERIES PROVIDER
// ============================================================

final expertQueriesProvider =
    FutureProvider.family<List<ExpertQuery>, String>((ref, userId) async {
  return SupabaseService.getExpertQueries(userId);
});

// ============================================================
// NOTIFICATIONS PROVIDER
// ============================================================

class NotificationsNotifier
    extends StateNotifier<AsyncValue<List<AppNotification>>> {
  NotificationsNotifier() : super(const AsyncValue.loading());

  Future<void> loadNotifications(String userId) async {
    try {
      final notifications = await SupabaseService.getNotifications(userId);
      state = AsyncValue.data(notifications);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsRead(String id) async {
    await SupabaseService.markNotificationRead(id);
    state.whenData((list) {
      state = AsyncValue.data(
        list
            .map((n) => n.id == id
                ? AppNotification(
                    id: n.id,
                    userId: n.userId,
                    title: n.title,
                    body: n.body,
                    type: n.type,
                    isRead: true,
                    createdAt: n.createdAt,
                  )
                : n)
            .toList(),
      );
    });
  }

  int get unreadCount =>
      state.whenOrNull(data: (list) => list.where((n) => !n.isRead).length) ??
      0;
}

final notificationsProvider = StateNotifierProvider<NotificationsNotifier,
    AsyncValue<List<AppNotification>>>((_) => NotificationsNotifier());

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifs = ref.watch(notificationsProvider);
  return notifs.whenOrNull(
        data: (list) => list.where((n) => !n.isRead).length,
      ) ??
      0;
});
