import 'package:flutter_test/flutter_test.dart';
import 'package:farmai/models/models.dart';

void main() {
  test('WeatherData.fromJson parses expected fields', () {
    final sampleJson = {
      'location': {
        'name': 'Test City',
        'region': 'Region'
      },
      'current': {
        'temp_c': 20.0,
        'feelslike_c': 22.0,
        'humidity': 55,
        'wind_kph': 12.0,
        'condition': {
          'text': 'Sunny',
          'icon': '//cdn.weatherapi.com/weather/64x64/day/113.png',
        },
        'precip_mm': 0.0,
        'uv': 5,
      },
      'forecast': {
        'forecastday': []
      }
    };

    final weather = WeatherData.fromJson(sampleJson);

    expect(weather.location, 'Test City, Region');
    expect(weather.temperature, 20.0);
    expect(weather.feelsLike, 22.0);
    expect(weather.humidity, 55);
    expect(weather.condition, 'Sunny');
    expect(weather.conditionIcon, '//cdn.weatherapi.com/weather/64x64/day/113.png');
    expect(weather.forecast, isEmpty);
  });

  test('UserModel serializes and deserializes correctly', () {
    final userJson = {
      'id': 'user-123',
      'email': 'tester@example.com',
      'full_name': 'Test Farmer',
      'phone': '1234567890',
      'profile_image_url': null,
      'location': 'Farmville',
      'farm_size': '2 acres',
      'primary_crops': ['Rice', 'Wheat'],
      'created_at': '2026-06-12T12:00:00.000Z',
    };

    final user = UserModel.fromJson(userJson);

    expect(user.id, 'user-123');
    expect(user.email, 'tester@example.com');
    expect(user.fullName, 'Test Farmer');
    expect(user.location, 'Farmville');
    expect(user.primaryCrops, contains('Rice'));
    expect(user.toJson()['email'], 'tester@example.com');
  });
}
