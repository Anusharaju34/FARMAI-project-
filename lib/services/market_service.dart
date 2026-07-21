import 'dart:async';
import 'dart:math';

class MarketService {
  MarketService._internal();

  static final MarketService _instance = MarketService._internal();

  factory MarketService() => _instance;

  Timer? _refreshTimer;

  DateTime? _lastUpdated;
  String? _lastError;

  final Random _random = Random();

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
      'advice':
          'Wheat prices are stable. Check local demand before selling.',
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
      'advice':
          'Maize prices are stable with a small increase expected.',
      'source': 'FARMAI Sample Market Data',
    },
  };

  Stream<Map<String, Map<String, dynamic>>> get marketDataStream =>
      _marketDataController.stream;

  Map<String, Map<String, dynamic>> get currentMarketData =>
      _copyMarketData();

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

    // Simulates market-price changes every 15 seconds.
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) {
        _updateStaticPrices();

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
    _updateStaticPrices();

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

    // Small loading delay for a natural refresh effect.
    await Future<void>.delayed(
      const Duration(milliseconds: 500),
    );

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
          cropName
              .toLowerCase()
              .contains(commodity.trim().toLowerCase());

      if (matchesState &&
          matchesDistrict &&
          matchesCommodity) {
        filteredData[cropName] =
            Map<String, dynamic>.from(data);
      }
    }

    _lastUpdated = DateTime.now();

    if (!_marketDataController.isClosed) {
      _marketDataController.add(filteredData);
    }
  }

  void _updateStaticPrices() {
    for (final entry in _marketData.entries) {
      final data = entry.value;

      final oldPrice = _toDouble(data['current']);

      // Creates a small price movement between -2% and +2%.
      final percentageChange =
          (_random.nextDouble() * 4) - 2;

      final newPrice =
          oldPrice + (oldPrice * percentageChange / 100);

      final roundedPrice =
          double.parse(newPrice.toStringAsFixed(0));

      final history = List<double>.from(
        data['history'] as List,
      );

      history.add(roundedPrice);

      if (history.length > 7) {
        history.removeAt(0);
      }

      final predictedPrice =
          roundedPrice * (1 + (_random.nextDouble() * 0.03));

      data['current'] = roundedPrice;
      data['predicted'] =
          double.parse(predictedPrice.toStringAsFixed(0));
      data['change'] =
          double.parse(percentageChange.toStringAsFixed(1));
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