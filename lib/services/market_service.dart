import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MarketService {
  MarketService._internal();

  static final MarketService _instance = MarketService._internal();

  factory MarketService() => _instance;

  Timer? _refreshTimer;

  DateTime? _lastUpdated;
  String? _lastError;

  final Random _random = Random();
  final Dio _dio = Dio();

  final StreamController<Map<String, Map<String, dynamic>>>
      _marketDataController =
      StreamController<Map<String, Map<String, dynamic>>>.broadcast();

  final Map<String, Map<String, dynamic>> _marketData = {
    'Rice': {
      'current': 2450.0,
      'minPrice': 2200.0,
      'maxPrice': 2700.0,
      'predicted': 2520.0,
      'unit': '₹/quintal',
      'change': 2.4,
      'isUp': true,
      'market': 'Chennai Market',
      'district': 'Chennai',
      'state': 'Tamil Nadu',
      'variety': 'Common',
      'grade': 'A',
      'arrivalDate': 'Today',
      'history': <double>[
        2200,
        2250,
        2300,
        2280,
        2350,
        2400,
        2450,
      ],
      'prediction': <double>[
        2470,
        2490,
        2500,
        2520,
      ],
      'advice':
          'Rice prices are increasing. Farmers may wait for a better selling price.',
      'source': 'FARMAI Sample Market Data',
    },
    'Wheat': {
      'current': 2300.0,
      'minPrice': 2100.0,
      'maxPrice': 2500.0,
      'predicted': 2350.0,
      'unit': '₹/quintal',
      'change': 1.8,
      'isUp': true,
      'market': 'Coimbatore Market',
      'district': 'Coimbatore',
      'state': 'Tamil Nadu',
      'variety': 'Local',
      'grade': 'A',
      'arrivalDate': 'Today',
      'history': <double>[
        2100,
        2150,
        2180,
        2200,
        2250,
        2280,
        2300,
      ],
      'prediction': <double>[
        2310,
        2325,
        2340,
        2350,
      ],
      'advice': 'Wheat prices are stable. Check local demand before selling.',
      'source': 'FARMAI Sample Market Data',
    },
    'Tomato': {
      'current': 3200.0,
      'minPrice': 2800.0,
      'maxPrice': 3600.0,
      'predicted': 3350.0,
      'unit': '₹/quintal',
      'change': 4.6,
      'isUp': true,
      'market': 'Koyambedu Market',
      'district': 'Chennai',
      'state': 'Tamil Nadu',
      'variety': 'Hybrid',
      'grade': 'A',
      'arrivalDate': 'Today',
      'history': <double>[
        2700,
        2800,
        2900,
        2850,
        3000,
        3100,
        3200,
      ],
      'prediction': <double>[
        3240,
        3280,
        3310,
        3350,
      ],
      'advice':
          'Tomato prices are rising. Selling in the coming days may provide a better return.',
      'source': 'FARMAI Sample Market Data',
    },
    'Onion': {
      'current': 2800.0,
      'minPrice': 2500.0,
      'maxPrice': 3100.0,
      'predicted': 2750.0,
      'unit': '₹/quintal',
      'change': -1.5,
      'isUp': false,
      'market': 'Madurai Market',
      'district': 'Madurai',
      'state': 'Tamil Nadu',
      'variety': 'Red Onion',
      'grade': 'A',
      'arrivalDate': 'Today',
      'history': <double>[
        3000,
        2950,
        2920,
        2900,
        2870,
        2830,
        2800,
      ],
      'prediction': <double>[
        2790,
        2780,
        2760,
        2750,
      ],
      'advice':
          'Onion prices are slightly decreasing. Consider selling based on your storage availability.',
      'source': 'FARMAI Sample Market Data',
    },
    'Potato': {
      'current': 2100.0,
      'minPrice': 1900.0,
      'maxPrice': 2350.0,
      'predicted': 2180.0,
      'unit': '₹/quintal',
      'change': 2.0,
      'isUp': true,
      'market': 'Salem Market',
      'district': 'Salem',
      'state': 'Tamil Nadu',
      'variety': 'Local',
      'grade': 'A',
      'arrivalDate': 'Today',
      'history': <double>[
        1900,
        1950,
        1980,
        2000,
        2030,
        2070,
        2100,
      ],
      'prediction': <double>[
        2120,
        2140,
        2160,
        2180,
      ],
      'advice':
          'Potato prices show a positive trend. Monitor the market before selling.',
      'source': 'FARMAI Sample Market Data',
    },
    'Maize': {
      'current': 2250.0,
      'minPrice': 2050.0,
      'maxPrice': 2450.0,
      'predicted': 2290.0,
      'unit': '₹/quintal',
      'change': 1.2,
      'isUp': true,
      'market': 'Erode Market',
      'district': 'Erode',
      'state': 'Tamil Nadu',
      'variety': 'Yellow',
      'grade': 'A',
      'arrivalDate': 'Today',
      'history': <double>[
        2050,
        2100,
        2120,
        2150,
        2180,
        2220,
        2250,
      ],
      'prediction': <double>[
        2260,
        2270,
        2280,
        2290,
      ],
      'advice': 'Maize prices are stable with a small increase expected.',
      'source': 'FARMAI Sample Market Data',
    },
  };

  Stream<Map<String, Map<String, dynamic>>> get marketDataStream =>
      _marketDataController.stream;

  Map<String, Map<String, dynamic>> get currentMarketData => _copyMarketData();

  DateTime? get lastUpdated => _lastUpdated;

  String? get lastError => _lastError;

  bool get hasData => _marketData.isNotEmpty;

  void startRealtimeUpdates({
    String state = 'Tamil Nadu',
    String? district,
    String? commodity,
  }) {
    _refreshTimer?.cancel();

    fetchLiveMarketPrices(
      state: state,
      district: district,
      commodity: commodity,
    );

    // Simulates or polls market-price changes every 15 seconds.
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) {
        fetchLiveMarketPrices(
          state: state,
          district: district,
          commodity: commodity,
        );
      },
    );
  }

  void stopRealtimeUpdates() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  Future<void> refresh({
    String state = 'Tamil Nadu',
    String? district,
    String? commodity,
  }) async {
    await fetchLiveMarketPrices(
      state: state,
      district: district,
      commodity: commodity,
    );
  }

  Future<void> fetchLiveMarketPrices({
    String state = 'Tamil Nadu',
    String? district,
    String? commodity,
    int limit = 100,
  }) async {
    _lastError = null;

    final apiKey = dotenv.env['DATA_GOV_IN_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      // Simulate live price updates locally if no API key is provided
      _updateStaticPrices();
      _lastUpdated = DateTime.now();

      final filteredData = _getLocalFilteredData(state, district, commodity);
      if (!_marketDataController.isClosed) {
        _marketDataController.add(filteredData);
      }
      return;
    }

    try {
      final Map<String, dynamic> queryParameters = {
        'api-key': apiKey,
        'format': 'json',
        'limit': limit,
      };

      if (state.trim().isNotEmpty) {
        queryParameters['filters[state]'] = state.trim();
      }
      if (district != null && district.trim().isNotEmpty) {
        queryParameters['filters[district]'] = district.trim();
      }
      if (commodity != null && commodity.trim().isNotEmpty) {
        queryParameters['filters[commodity]'] = commodity.trim();
      }

      final response = await _dio.get(
        'https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a86454359444',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200 && response.data != null) {
        final records = response.data['records'] as List?;
        if (records != null && records.isNotEmpty) {
          final liveData = <String, Map<String, dynamic>>{};

          for (final record in records) {
            final rawCrop = record['commodity']?.toString() ?? 'Unknown';
            // Capitalize commodity name
            final cropName = rawCrop.substring(0, 1).toUpperCase() +
                rawCrop.substring(1).toLowerCase();

            final currentVal = _toDouble(record['modal_price']);
            final minVal = _toDouble(record['min_price']);
            final maxVal = _toDouble(record['max_price']);

            final existingCrop = _marketData[cropName];
            final history = existingCrop != null
                ? List<double>.from(existingCrop['history'] as List)
                : <double>[minVal, (minVal + maxVal) / 2, maxVal];

            if (history.isEmpty || history.last != currentVal) {
              history.add(currentVal);
              if (history.length > 7) {
                history.removeAt(0);
              }
            }

            final double change =
                existingCrop != null && _toDouble(existingCrop['current']) > 0
                    ? ((currentVal - _toDouble(existingCrop['current'])) /
                        _toDouble(existingCrop['current']) *
                        100)
                    : 0.0;

            final isUp = change >= 0;

            liveData[cropName] = {
              'current': currentVal,
              'minPrice': minVal,
              'maxPrice': maxVal,
              'predicted': currentVal * 1.02,
              'unit': '₹/quintal',
              'change': double.parse(change.toStringAsFixed(1)),
              'isUp': isUp,
              'market': record['market']?.toString() ?? 'Mandi',
              'district': record['district']?.toString() ?? '',
              'state': record['state']?.toString() ?? '',
              'variety': record['variety']?.toString() ?? 'Common',
              'grade': record['grade']?.toString() ?? 'A',
              'arrivalDate': record['arrival_date']?.toString() ?? 'Today',
              'history': history,
              'prediction': <double>[
                currentVal,
                currentVal * 1.01,
                currentVal * 1.02,
                currentVal * 1.03,
              ],
              'advice': 'Real-time market price loaded via Agmarknet API.',
              'source': 'data.gov.in / AGMARKNET',
            };

            // Update local memory map
            _marketData[cropName] = liveData[cropName]!;
          }

          _lastUpdated = DateTime.now();
          if (!_marketDataController.isClosed) {
            _marketDataController.add(liveData);
          }
          return;
        }
      }
      throw Exception('Empty response or invalid data format from APMC API.');
    } catch (error) {
      _lastError = 'API Error: $error. Running in simulation mode.';
      _updateStaticPrices();
      _lastUpdated = DateTime.now();

      final filteredData = _getLocalFilteredData(state, district, commodity);
      if (!_marketDataController.isClosed) {
        _marketDataController.add(filteredData);
      }
    }
  }

  Map<String, Map<String, dynamic>> _getLocalFilteredData(
    String state,
    String? district,
    String? commodity,
  ) {
    final filteredData = <String, Map<String, dynamic>>{};
    for (final entry in _marketData.entries) {
      final cropName = entry.key;
      final data = entry.value;

      final matchesState = state.trim().isEmpty ||
          data['state']
              .toString()
              .toLowerCase()
              .contains(state.trim().toLowerCase());

      final matchesDistrict = district == null ||
          district.trim().isEmpty ||
          data['district']
              .toString()
              .toLowerCase()
              .contains(district.trim().toLowerCase());

      final matchesCommodity = commodity == null ||
          commodity.trim().isEmpty ||
          cropName.toLowerCase().contains(commodity.trim().toLowerCase());

      if (matchesState && matchesDistrict && matchesCommodity) {
        filteredData[cropName] = Map<String, dynamic>.from(data);
      }
    }
    return filteredData;
  }

  void _updateStaticPrices() {
    for (final entry in _marketData.entries) {
      final data = entry.value;

      final oldPrice = _toDouble(data['current']);

      // Creates a small price movement between -2% and +2%.
      final percentageChange = (_random.nextDouble() * 4) - 2;

      final newPrice = oldPrice + (oldPrice * percentageChange / 100);

      final roundedPrice = double.parse(newPrice.toStringAsFixed(0));

      final history = List<double>.from(
        data['history'] as List,
      );

      history.add(roundedPrice);

      if (history.length > 7) {
        history.removeAt(0);
      }

      final predictedPrice = roundedPrice * (1 + (_random.nextDouble() * 0.03));

      data['current'] = roundedPrice;
      data['predicted'] = double.parse(predictedPrice.toStringAsFixed(0));
      data['change'] = double.parse(percentageChange.toStringAsFixed(1));
      data['isUp'] = percentageChange >= 0;
      data['history'] = history;
      data['prediction'] = <double>[
        roundedPrice,
        roundedPrice * 1.01,
        roundedPrice * 1.02,
        predictedPrice,
      ];
      data['arrivalDate'] = 'Today';
    }
  }

  Map<String, Map<String, dynamic>> _copyMarketData() {
    return _marketData.map(
      (key, value) => MapEntry(
        key,
        Map<String, dynamic>.from(value),
      ),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  void dispose() {
    stopRealtimeUpdates();

    if (!_marketDataController.isClosed) {
      _marketDataController.close();
    }
  }
}
