import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmai/services/weather_service.dart';
import 'package:farmai/models/models.dart';

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: '');
  });

  test('WeatherService returns fallback weather data when API is unavailable', () async {
    final weather = await WeatherService.getCurrentWeather('Testville');

    expect(weather, isNotNull);
    expect(weather, isA<WeatherData>());
    expect(weather!.location, contains('Testville'));
    expect(weather.temperature, greaterThanOrEqualTo(0));
    expect(weather.forecast, hasLength(5));
    expect(weather.forecast.first.condition, isNotEmpty);
  });
}
