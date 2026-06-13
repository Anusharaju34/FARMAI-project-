import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:farmai/models/models.dart';
import 'package:farmai/providers/providers.dart';

// Helper to generate a mock supabase User object
sb.User getMockSupabaseUser() {
  return sb.User(
    id: 'test-user-uuid-123',
    appMetadata: {},
    userMetadata: {'full_name': 'Ravi Kumar'},
    aud: 'authenticated',
    email: 'farmer@example.com',
    createdAt: DateTime.now().toIso8601String(),
  );
}

final mockUserModel = UserModel(
  id: 'test-user-uuid-123',
  email: 'farmer@example.com',
  fullName: 'Ravi Kumar',
  phone: '9876543210',
  location: 'Salem, Tamil Nadu',
  farmSize: '2.5 Hectares',
  primaryCrops: ['Rice', 'Tomato'],
  createdAt: DateTime.now(),
);

final mockWeatherData = WeatherData(
  location: 'Salem, India',
  temperature: 31.5,
  feelsLike: 34.0,
  humidity: 65,
  windSpeed: 12.0,
  condition: 'Sunny',
  conditionIcon: '//cdn.weatherapi.com/weather/64x64/day/113.png',
  rainfall: 0.0,
  uvIndex: 8,
  forecast: [
    WeatherForecast(
      date: DateTime.now(),
      maxTemp: 33,
      minTemp: 25,
      condition: 'Sunny',
      chanceOfRain: 10,
    ),
  ],
);

final List<MarketPrice> mockMarketPrices = [
  MarketPrice(
    id: 'mp-1',
    cropName: 'Rice',
    currentPrice: 2450.0,
    predictedPrice: 2500.0,
    priceUnit: '₹/quintal',
    market: 'Salem APMC',
    changePercent: 2.04,
    updatedAt: DateTime.now(),
  ),
  MarketPrice(
    id: 'mp-2',
    cropName: 'Tomato',
    currentPrice: 1200.0,
    predictedPrice: 1100.0,
    priceUnit: '₹/crate',
    market: 'Salem APMC',
    changePercent: -8.33,
    updatedAt: DateTime.now(),
  ),
];

final List<AppNotification> mockNotifications = [
  AppNotification(
    id: 'notif-1',
    userId: 'test-user-uuid-123',
    title: '💧 Irrigation Reminder',
    body: 'Time to water Rice field. Recommended: 15m³.',
    type: 'irrigation',
    isRead: false,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  AppNotification(
    id: 'notif-2',
    userId: 'test-user-uuid-123',
    title: '⚠️ Disease Alert',
    body: 'High Leaf Blight risk detected in your region.',
    type: 'disease',
    isRead: true,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
];

final List<ForumPost> mockForumPosts = [
  ForumPost(
    id: 'post-1',
    userId: 'user-abc',
    userFullName: 'Anil Kumar',
    title: 'Best organic fertilizer for Tomato crop?',
    content: 'Suggest good organic options to improve yield. Soil is loamy.',
    likesCount: 15,
    commentsCount: 4,
    isLiked: true,
    tags: ['Tomato', 'Fertilizer'],
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
];

final List<ExpertQuery> mockExpertQueries = [
  ExpertQuery(
    id: 'eq-1',
    userId: 'test-user-uuid-123',
    subject: 'Yellow spots on Rice leaves',
    question: 'Upper leaves are turning yellow with brown spots. What is it?',
    status: 'answered',
    category: 'Diseases',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    expertReply: 'Looks like Brown Spot disease. Apply Hexaconazole 5% EC at 2ml per liter of water.',
    repliedAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
];

final List<DiseasePrediction> mockDiseasePredictions = [
  DiseasePrediction(
    id: 'dp-1',
    userId: 'test-user-uuid-123',
    imageUrl: 'https://example.com/leaf.png',
    diseaseName: 'Leaf Blight',
    confidenceScore: 0.945,
    cropType: 'Rice',
    treatmentSuggestions: ['Use certified seeds', 'Apply Propiconazole fungicide'],
    severity: 'Medium',
    createdAt: DateTime.now(),
  ),
];

// Mock Notifiers to prevent contacting SupabaseService in widgets
class MockAuthNotifier extends AuthNotifier {
  @override
  Future<bool> signIn(String email, String password) async => true;
  @override
  Future<bool> signUp(String email, String password, String fullName) async => true;
  @override
  Future<void> signOut() async {}
}

class MockNotificationsNotifier extends NotificationsNotifier {
  final List<AppNotification> initialList;
  MockNotificationsNotifier(this.initialList) {
    state = AsyncValue.data(initialList);
  }
  @override
  Future<void> loadNotifications(String userId) async {
    await Future.delayed(Duration.zero);
    if (mounted) {
      state = AsyncValue.data(initialList);
    }
  }
  @override
  Future<void> markAsRead(String id) async {
    await Future.delayed(Duration.zero);
    if (mounted) {
      state.whenData((value) {
        state = AsyncValue.data(value.map((n) => n.id == id ? AppNotification(
          id: n.id,
          userId: n.userId,
          title: n.title,
          body: n.body,
          type: n.type,
          isRead: true,
          createdAt: n.createdAt,
        ) : n).toList());
      });
    }
  }
}

class MockForumPostsNotifier extends ForumPostsNotifier {
  final List<ForumPost> initialList;
  MockForumPostsNotifier(this.initialList) {
    state = AsyncValue.data(initialList);
  }
  @override
  Future<void> loadPosts({String? search}) async {
    await Future.delayed(Duration.zero);
    if (mounted) {
      state = AsyncValue.data(initialList);
    }
  }
  @override
  Future<void> createPost(Map<String, dynamic> data) async {
    await Future.delayed(Duration.zero);
    if (mounted) {
      final newPost = ForumPost(
        id: 'post-${DateTime.now().millisecondsSinceEpoch}',
        userId: 'test-user-uuid-123',
        userFullName: 'Ravi Kumar',
        title: data['title'] as String,
        content: data['content'] as String,
        likesCount: 0,
        commentsCount: 0,
        isLiked: false,
        tags: (data['tags'] as List<dynamic>).cast<String>(),
        createdAt: DateTime.now(),
      );
      state = AsyncValue.data([newPost, ...initialList]);
    }
  }
}

void initMockSupabase() {
  try {
    sb.Supabase.initialize(
      url: 'https://example.supabase.co',
      anonKey: 'test-anon-key',
      authOptions: const sb.FlutterAuthClientOptions(
        autoRefreshToken: false,
      ),
    );
  } catch (e) {
    // Suppress if already initialized
  }
}

// Global list of overrides for clean widget testing
List<Override> getTestProviderOverrides() {
  initMockSupabase();
  return [
    currentUserProvider.overrideWithValue(getMockSupabaseUser()),
    userProfileProvider('test-user-uuid-123').overrideWith((ref) => Future.value(mockUserModel)),
    weatherProvider('Chennai, India').overrideWith((ref) => Future.value(mockWeatherData)),
    weatherProvider('Salem, India').overrideWith((ref) => Future.value(mockWeatherData)),
    marketPricesProvider.overrideWith((ref) => Future.value(mockMarketPrices)),
    expertQueriesProvider('test-user-uuid-123').overrideWith((ref) => Future.value(mockExpertQueries)),
    diseasePredictionsProvider('test-user-uuid-123').overrideWith((ref) => Future.value(mockDiseasePredictions)),
    
    // Notifier overrides
    authNotifierProvider.overrideWith((_) => MockAuthNotifier()),
    notificationsProvider.overrideWith((_) => MockNotificationsNotifier(mockNotifications)),
    forumPostsProvider.overrideWith((_) => MockForumPostsNotifier(mockForumPosts)),
  ];
}

// Utility to wrap testing screen with providers, disabling animations and injecting scaffolding
Widget buildTestableWidget(Widget child, {List<Override>? overrides}) {
  initMockSupabase();
  return ProviderScope(
    overrides: overrides ?? getTestProviderOverrides(),
    child: MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: Scaffold(
          body: child,
        ),
      ),
    ),
  );
}
