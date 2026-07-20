// ============================================================
// USER MODEL
// ============================================================
class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String? profileImageUrl;
  final String? location;
  final String? farmSize;
  final List<String>? primaryCrops;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.profileImageUrl,
    this.location,
    this.farmSize,
    this.primaryCrops,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        email: json['email'] as String,
        fullName: json['full_name'] as String? ?? '',
        phone: json['phone'] as String?,
        profileImageUrl: json['profile_image_url'] as String?,
        location: json['location'] as String?,
        farmSize: json['farm_size'] as String?,
        primaryCrops: (json['primary_crops'] as List<dynamic>?)?.cast<String>(),
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'full_name': fullName,
        'phone': phone,
        'profile_image_url': profileImageUrl,
        'location': location,
        'farm_size': farmSize,
        'primary_crops': primaryCrops,
        'created_at': createdAt.toIso8601String(),
      };
}

// ============================================================
// DISEASE PREDICTION MODEL
// ============================================================
class DiseasePrediction {
  final String id;
  final String userId;
  final String imageUrl;
  final String diseaseName;
  final double confidenceScore;
  final String cropType;
  final List<String> treatmentSuggestions;
  final String severity;
  final DateTime createdAt;

  const DiseasePrediction({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.diseaseName,
    required this.confidenceScore,
    required this.cropType,
    required this.treatmentSuggestions,
    required this.severity,
    required this.createdAt,
  });

  factory DiseasePrediction.fromJson(Map<String, dynamic> json) =>
      DiseasePrediction(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        imageUrl: json['image_url'] as String,
        diseaseName: json['disease_name'] as String,
        confidenceScore: (json['confidence_score'] as num).toDouble(),
        cropType: json['crop_type'] as String,
        treatmentSuggestions:
            (json['treatment_suggestions'] as List<dynamic>).cast<String>(),
        severity: json['severity'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

// ============================================================
// PEST DETECTION MODEL
// ============================================================
class PestDetection {
  final String id;
  final String userId;
  final String imageUrl;
  final String pestName;
  final double confidenceScore;
  final String severityLevel;
  final List<String> preventionRecommendations;
  final DateTime createdAt;

  const PestDetection({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.pestName,
    required this.confidenceScore,
    required this.severityLevel,
    required this.preventionRecommendations,
    required this.createdAt,
  });

  factory PestDetection.fromJson(Map<String, dynamic> json) => PestDetection(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        imageUrl: json['image_url'] as String,
        pestName: json['pest_name'] as String,
        confidenceScore: (json['confidence_score'] as num).toDouble(),
        severityLevel: json['severity_level'] as String,
        preventionRecommendations:
            (json['prevention_recommendations'] as List<dynamic>)
                .cast<String>(),
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

// ============================================================
// WEATHER MODEL
// ============================================================
class WeatherData {
  final String location;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String condition;
  final String conditionIcon;
  final double rainfall;
  final int uvIndex;
  final List<WeatherForecast> forecast;

  const WeatherData({
    required this.location,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.condition,
    required this.conditionIcon,
    required this.rainfall,
    required this.uvIndex,
    required this.forecast,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    final locationData = json['location'] as Map<String, dynamic>;
    return WeatherData(
      location: '${locationData['name']}, ${locationData['region']}',
      temperature: (current['temp_c'] as num).toDouble(),
      feelsLike: (current['feelslike_c'] as num).toDouble(),
      humidity: current['humidity'] as int,
      windSpeed: (current['wind_kph'] as num).toDouble(),
      condition: current['condition']['text'] as String,
      conditionIcon: current['condition']['icon'] as String,
      rainfall: (current['precip_mm'] as num? ?? 0).toDouble(),
      uvIndex: (current['uv'] as num? ?? 0).toInt(),
      forecast: [],
    );
  }
}

class WeatherForecast {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final String condition;
  final double chanceOfRain;

  const WeatherForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.condition,
    required this.chanceOfRain,
  });
}

// ============================================================
// MARKET PRICE MODEL
// ============================================================
class MarketPrice {
  final String id;
  final String cropName;
  final double currentPrice;
  final double predictedPrice;
  final String priceUnit;
  final String market;
  final double changePercent;
  final DateTime updatedAt;
  final List<PricePoint> history;

  const MarketPrice({
    required this.id,
    required this.cropName,
    required this.currentPrice,
    required this.predictedPrice,
    required this.priceUnit,
    required this.market,
    required this.changePercent,
    required this.updatedAt,
    this.history = const [],
  });

  factory MarketPrice.fromJson(Map<String, dynamic> json) => MarketPrice(
        id: json['id'] as String,
        cropName: json['crop_name'] as String,
        currentPrice: (json['current_price'] as num).toDouble(),
        predictedPrice: (json['predicted_price'] as num).toDouble(),
        priceUnit: json['price_unit'] as String? ?? '₹/quintal',
        market: json['market'] as String? ?? 'APMC',
        changePercent: (json['change_percent'] as num? ?? 0).toDouble(),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );
}

class PricePoint {
  final DateTime date;
  final double price;
  const PricePoint({required this.date, required this.price});
}

// ============================================================
// IRRIGATION RECORD MODEL
// ============================================================
class IrrigationRecord {
  final String id;
  final String userId;
  final String cropType;
  final String soilType;
  final double waterRequired;
  final String schedule;
  final List<String> recommendations;
  final DateTime createdAt;

  const IrrigationRecord({
    required this.id,
    required this.userId,
    required this.cropType,
    required this.soilType,
    required this.waterRequired,
    required this.schedule,
    required this.recommendations,
    required this.createdAt,
  });

  factory IrrigationRecord.fromJson(Map<String, dynamic> json) =>
      IrrigationRecord(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        cropType: json['crop_type'] as String,
        soilType: json['soil_type'] as String,
        waterRequired: (json['water_required'] as num).toDouble(),
        schedule: json['schedule'] as String,
        recommendations:
            (json['recommendations'] as List<dynamic>).cast<String>(),
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

// ============================================================
// FORUM POST MODEL
// ============================================================
class ForumPost {
  final String id;
  final String userId;
  final String userFullName;
  final String? userImageUrl;
  final String title;
  final String content;
  final String? imageUrl;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final List<String> tags;
  final DateTime createdAt;

  const ForumPost({
    required this.id,
    required this.userId,
    required this.userFullName,
    this.userImageUrl,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
    required this.tags,
    required this.createdAt,
  });

  factory ForumPost.fromJson(Map<String, dynamic> json) => ForumPost(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        userFullName: json['user_full_name'] as String? ?? 'Farmer',
        userImageUrl: json['user_image_url'] as String?,
        title: json['title'] as String,
        content: json['content'] as String,
        imageUrl: json['image_url'] as String?,
        likesCount: json['likes_count'] as int? ?? 0,
        commentsCount: json['comments_count'] as int? ?? 0,
        isLiked: json['is_liked'] as bool? ?? false,
        tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

// ============================================================
// EXPERT QUERY MODEL
// ============================================================
class ExpertQuery {
  final String id;
  final String userId;
  final String subject;
  final String question;
  final String? expertReply;
  final String status; // pending, answered, closed
  final String category;
  final DateTime createdAt;
  final DateTime? repliedAt;

  const ExpertQuery({
    required this.id,
    required this.userId,
    required this.subject,
    required this.question,
    this.expertReply,
    required this.status,
    required this.category,
    required this.createdAt,
    this.repliedAt,
  });

  factory ExpertQuery.fromJson(Map<String, dynamic> json) => ExpertQuery(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        subject: json['subject'] as String,
        question: json['question'] as String,
        expertReply: json['expert_reply'] as String?,
        status: json['status'] as String? ?? 'pending',
        category: json['category'] as String? ?? 'General',
        createdAt: DateTime.parse(json['created_at'] as String),
        repliedAt: json['replied_at'] != null
            ? DateTime.parse(json['replied_at'] as String)
            : null,
      );
}

// ============================================================
// NOTIFICATION MODEL
// ============================================================
class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type; // disease, pest, weather, market, system
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        type: json['type'] as String? ?? 'system',
        isRead: json['is_read'] as bool? ?? false,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
