class AppConstants {
  AppConstants._();

  // Supabase Tables
  static const String usersTable = 'users';
  static const String diseasePredictionsTable = 'disease_predictions';
  static const String pestDetectionsTable = 'pest_detections';
  static const String weatherAlertsTable = 'weather_alerts';
  static const String marketPredictionsTable = 'market_predictions';
  static const String irrigationRecordsTable = 'irrigation_records';
  static const String forumPostsTable = 'forum_posts';
  static const String forumCommentsTable = 'forum_comments';
  static const String expertQueriesTable = 'expert_queries';
  static const String notificationsTable = 'notifications';

  // Supabase Storage Buckets
  static const String cropImagesBucket = 'crop-images';
  static const String pestImagesBucket = 'pest-images';
  static const String profileImagesBucket = 'profile-images';

  // Shared Prefs Keys
  static const String onboardingKey = 'onboarding_complete';
  static const String themeKey = 'theme_mode';

  // Durations
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 350);
  static const Duration animationSlow = Duration(milliseconds: 600);

  // Padding
  static const double paddingXS = 4.0;
  static const double paddingSM = 8.0;
  static const double paddingMD = 16.0;
  static const double paddingLG = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;

  // Border Radius
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusXXL = 32.0;
  static const double radiusFull = 100.0;

  // Crop Types
  static const List<String> cropTypes = [
    'Rice',
    'Wheat',
    'Maize',
    'Cotton',
    'Sugarcane',
    'Soybean',
    'Tomato',
    'Potato',
    'Onion',
    'Chili',
    'Groundnut',
    'Sunflower',
    'Mustard',
    'Turmeric',
    'Ginger',
  ];

  // Soil Types
  static const List<String> soilTypes = [
    'Clay',
    'Sandy',
    'Loamy',
    'Silty',
    'Peaty',
    'Chalky',
    'Black Cotton',
  ];
}
