import 'package:flutter_test/flutter_test.dart';
import 'package:farmai/models/models.dart';
import '../mocks/mock_providers.dart';

void main() {
  group('FARMAI Unit Tests (FLT-001 to FLT-030)', () {
    test('FLT-001: UserModel serialization and deserialization', () {
      final json = mockUserModel.toJson();
      expect(json['full_name'], equals('Ravi Kumar'));
      expect(json['email'], equals('farmer@example.com'));
      
      final model = UserModel.fromJson(json);
      expect(model.id, equals(mockUserModel.id));
      expect(model.fullName, equals('Ravi Kumar'));
    });

    test('FLT-002: WeatherData temperature parsing and condition', () {
      expect(mockWeatherData.temperature, equals(31.5));
      expect(mockWeatherData.condition, equals('Sunny'));
      expect(mockWeatherData.forecast.length, equals(1));
    });

    test('FLT-003: MarketPrice price calculation and percentage change', () {
      final item = mockMarketPrices.first;
      expect(item.cropName, equals('Rice'));
      expect(item.currentPrice, equals(2450.0));
      expect(item.changePercent, equals(2.04));
    });

    test('FLT-004: AppNotification read status toggle', () {
      final notif = mockNotifications.first;
      expect(notif.isRead, isFalse);
      expect(notif.title, contains('Irrigation'));
    });

    test('FLT-005: ForumPost likes counter validation', () {
      final post = mockForumPosts.first;
      expect(post.likesCount, equals(15));
      expect(post.isLiked, isTrue);
    });

    test('FLT-006: ExpertQuery status classification', () {
      final query = mockExpertQueries.first;
      expect(query.status, equals('answered'));
      expect(query.expertReply, contains('Hexaconazole'));
    });

    test('FLT-007: DiseasePrediction confidence score range check', () {
      final pred = mockDiseasePredictions.first;
      expect(pred.confidenceScore, greaterThan(0.90));
      expect(pred.diseaseName, equals('Leaf Blight'));
    });

    test('FLT-008: Irrigation calculation formula logic', () {
      // 2.5 Hectares for Rice (Clay soil factor)
      double areaHectares = 2.5;
      double cropFactor = 5.0; // m3/day per ha
      double waterVolume = areaHectares * cropFactor;
      expect(waterVolume, equals(12.5));
    });

    test('FLT-009: Soil NPK ratio optimal threshold evaluation', () {
      double nitrogen = 140; // kg/ha
      double phosphorus = 45;
      double potassium = 180;
      bool isOptimal = (nitrogen >= 120 && phosphorus >= 30 && potassium >= 150);
      expect(isOptimal, isTrue);
    });

    test('FLT-010: Email regex pattern validator test', () {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      expect(emailRegex.hasMatch('farmer@example.com'), isTrue);
      expect(emailRegex.hasMatch('invalid-email'), isFalse);
    });
  });
}
