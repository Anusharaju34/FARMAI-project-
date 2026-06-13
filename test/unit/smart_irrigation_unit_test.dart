import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> calculateIrrigationAdvice(
    String crop, String soil, double area) {
  final cropWater = {
    'Rice': 8.0, 'Wheat': 5.5, 'Maize': 6.0, 'Cotton': 7.0,
    'Sugarcane': 9.0, 'Tomato': 5.0, 'Potato': 4.5, 'Onion': 4.0,
    'Soybean': 5.5, 'Groundnut': 5.0,
  };

  final soilFactor = {
    'Clay': 0.8, 'Sandy': 1.4, 'Loamy': 1.0, 'Silty': 0.9,
    'Peaty': 0.7, 'Chalky': 1.1, 'Black Cotton': 0.75,
  };

  final baseWater = cropWater[crop] ?? 5.5;
  final factor = soilFactor[soil] ?? 1.0;
  final dailyWater = baseWater * factor * area;
  final weeklyWater = dailyWater * 7;

  return {
    'waterRequired': dailyWater,
    'weeklyTotal': weeklyWater,
    'schedule': 'Every ${getFrequency(crop, soil)} days',
    'method': getBestMethod(crop, soil),
  };
}

String getFrequency(String crop, String soil) {
  if (soil == 'Sandy') return '1–2';
  if (soil == 'Clay') return '4–5';
  if (crop == 'Rice') return '2–3';
  return '3–4';
}

String getBestMethod(String crop, String soil) {
  if (crop == 'Rice') return 'Flood Irrigation';
  if (soil == 'Sandy') return 'Drip Irrigation';
  if (['Tomato', 'Potato', 'Onion'].contains(crop)) return 'Drip / Sprinkler';
  return 'Furrow / Sprinkler';
}

void main() {
  group('Smart Irrigation Advice Engine', () {
    test('calculates correct daily and weekly water requirements', () {
      // Rice (8.0) + Clay (0.8) + Area (2.0 hectares) = 8.0 * 0.8 * 2.0 = 12.8 m3/day
      final advice = calculateIrrigationAdvice('Rice', 'Clay', 2.0);
      expect(advice['waterRequired'], closeTo(12.8, 0.001));
      expect(advice['weeklyTotal'], closeTo(89.6, 0.001));
      expect(advice['schedule'], 'Every 4–5 days');
      expect(advice['method'], 'Flood Irrigation');
    });

    test('calculates correct advice for Wheat on Sandy soil', () {
      // Wheat (5.5) + Sandy (1.4) + Area (1.0) = 5.5 * 1.4 * 1.0 = 7.7 m3/day
      final advice = calculateIrrigationAdvice('Wheat', 'Sandy', 1.0);
      expect(advice['waterRequired'], closeTo(7.7, 0.001));
      expect(advice['weeklyTotal'], closeTo(53.9, 0.001));
      expect(advice['schedule'], 'Every 1–2 days');
      expect(advice['method'], 'Drip Irrigation');
    });

    test('calculates correct advice for Tomato on Loamy soil', () {
      // Tomato (5.0) + Loamy (1.0) + Area (1.5) = 5.0 * 1.0 * 1.5 = 7.5 m3/day
      final advice = calculateIrrigationAdvice('Tomato', 'Loamy', 1.5);
      expect(advice['waterRequired'], closeTo(7.5, 0.001));
      expect(advice['method'], 'Drip / Sprinkler');
    });
  });
}
