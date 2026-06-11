import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/models.dart';

class WeatherService {
  static final _dio = Dio();
  static String get _apiKey => dotenv.env['WEATHER_API_KEY'] ?? '';
  static const _baseUrl = 'https://api.weatherapi.com/v1';

  static Future<WeatherData?> getCurrentWeather(String location) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/forecast.json',
        queryParameters: {
          'key': _apiKey,
          'q': location,
          'days': 7,
          'aqi': 'yes',
          'alerts': 'yes',
        },
      );
      return WeatherData.fromJson(response.data);
    } catch (e) {
      return _getMockWeather(location);
    }
  }

  // Mock weather for development
  static WeatherData _getMockWeather(String location) {
    return WeatherData(
      location: location,
      temperature: 28.5,
      feelsLike: 31.0,
      humidity: 72,
      windSpeed: 14.0,
      condition: 'Partly Cloudy',
      conditionIcon: '//cdn.weatherapi.com/weather/64x64/day/116.png',
      rainfall: 0.0,
      uvIndex: 6,
      forecast: [
        WeatherForecast(
          date: DateTime.now(),
          maxTemp: 32,
          minTemp: 24,
          condition: 'Sunny',
          chanceOfRain: 10,
        ),
        WeatherForecast(
          date: DateTime.now().add(const Duration(days: 1)),
          maxTemp: 29,
          minTemp: 22,
          condition: 'Cloudy',
          chanceOfRain: 40,
        ),
        WeatherForecast(
          date: DateTime.now().add(const Duration(days: 2)),
          maxTemp: 27,
          minTemp: 21,
          condition: 'Rain',
          chanceOfRain: 80,
        ),
        WeatherForecast(
          date: DateTime.now().add(const Duration(days: 3)),
          maxTemp: 30,
          minTemp: 23,
          condition: 'Partly Cloudy',
          chanceOfRain: 20,
        ),
        WeatherForecast(
          date: DateTime.now().add(const Duration(days: 4)),
          maxTemp: 33,
          minTemp: 25,
          condition: 'Sunny',
          chanceOfRain: 5,
        ),
      ],
    );
  }
}
