import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';
import '../../routes/app_router.dart';

class MarketPriceScreen extends StatefulWidget {
  const MarketPriceScreen({super.key});

  @override
  State<MarketPriceScreen> createState() => _MarketPriceScreenState();
}

class _MarketPriceScreenState extends State<MarketPriceScreen>
    with SingleTickerProviderStateMixin {
  String _selectedCrop = 'Rice';
  late TabController _tabController;

  final List<String> _crops = [
    'Rice', 'Wheat', 'Maize', 'Cotton', 'Tomato',
    'Onion', 'Potato', 'Sugarcane', 'Soybean', 'Groundnut',
  ];

  final Map<String, Map<String, dynamic>> _cropData = {
    'Rice': {
      'current': 2340.0,
      'predicted': 2480.0,
      'unit': '₹/quintal',
      'change': 2.3,
      'isUp': true,
      'market': 'APMC Mumbai',
      'history': [2100.0, 2180.0, 2250.0, 2200.0, 2300.0, 2340.0],
      'prediction': [2340.0, 2380.0, 2420.0, 2460.0, 2480.0],
      'advice': 'Good time to sell. Prices expected to rise 6% over next 2 weeks due to export demand.',
    },
    'Wheat': {
      'current': 1890.0,
      'predicted': 1820.0,
      'unit': '₹/quintal',
      'change': -0.8,
      'isUp': false,
      'market': 'APMC Delhi',
      'history': [1950.0, 1930.0, 1910.0, 1900.0, 1905.0, 1890.0],
      'prediction': [1890.0, 1870.0, 1850.0, 1830.0, 1820.0],
      'advice': 'Consider holding stock. Prices expected to stabilize in 3 weeks post harvest season.',
    },
    'Tomato': {
      'current': 890.0,
      'predicted': 1100.0,
      'unit': '₹/quintal',
      'change': 5.1,
      'isUp': true,
      'market': 'APMC Bangalore',
      'history': [650.0, 700.0, 780.0, 820.0, 860.0, 890.0],
      'prediction': [890.0, 950.0, 1020.0, 1080.0, 1100.0],
      'advice': 'Strong upward trend. Excellent selling opportunity. Short supply due to rainfall damage.',
    },
    'Maize': {
      'current': 1780.0,
      'predicted': 1850.0,
      'unit': '₹/quintal',
      'change': 1.2,
      'isUp': true,
      'market': 'APMC Pune',
      'history': [1680.0, 1710.0, 1740.0, 1760.0, 1775.0, 1780.0],
      'prediction': [1780.0, 1800.0, 1820.0, 1840.0, 1850.0],
      'advice': 'Steady growth. Poultry feed demand driving prices up.',
    },
    'Cotton': {
      'current': 6450.0,
      'predicted': 6700.0,
      'unit': '₹/quintal',
      'change': 1.8,
      'isUp': true,
      'market': 'Rajkot Market',
      'history': [5900.0, 6050.0, 6180.0, 6300.0, 6400.0, 6450.0],
      'prediction': [6450.0, 6520.0, 6580.0, 6640.0, 6700.0],
      'advice': 'Mill demand strong. Prices supported by lower Kharif acreage.',
    },
    'Onion': {'current': 1240.0, 'predicted': 1050.0, 'unit': '₹/quintal', 'change': -3.2, 'isUp': false, 'market': 'Lasalgaon APMC', 'history': [1500.0, 1450.0, 1380.0, 1320.0, 1270.0, 1240.0], 'prediction': [1240.0, 1180.0, 1120.0, 1080.0, 1050.0], 'advice': 'Prices declining. Sell current stock soon before new arrivals flood market.'},
    'Potato': {'current': 980.0, 'predicted': 1050.0, 'unit': '₹/quintal', 'change': 0.5, 'isUp': true, 'market': 'Agra Market', 'history': [900.0, 920.0, 940.0, 960.0, 975.0, 980.0], 'prediction': [980.0, 1000.0, 1020.0, 1040.0, 1050.0], 'advice': 'Cold storage demand keeping prices stable with mild upward bias.'},
    'Sugarcane': {'current': 315.0, 'predicted': 320.0, 'unit': '₹/quintal', 'change': 0.3, 'isUp': true, 'market': 'UP State Price', 'history': [305.0, 308.0, 310.0, 312.0, 314.0, 315.0], 'prediction': [315.0, 316.0, 317.0, 318.0, 320.0], 'advice': 'Government SAP (State Advised Price) provides price stability.'},
    'Soybean': {'current': 4120.0, 'predicted': 4350.0, 'unit': '₹/quintal', 'change': 3.4, 'isUp': true, 'market': 'Indore APMC', 'history': [3800.0, 3900.0, 4000.0, 4050.0, 4100.0, 4120.0], 'prediction': [4120.0, 4200.0, 4260.0, 4310.0, 4350.0], 'advice': 'Oilmeal exports boosting demand. Good time to sell.'},
    'Groundnut': {'current': 5890.0, 'predicted': 6100.0, 'unit': '₹/quintal', 'change': 2.1, 'isUp': true, 'market': 'Junagadh Market', 'history': [5600.0, 5680.0, 5750.0, 5810.0, 5860.0, 5890.0], 'prediction': [5890.0, 5940.0, 6000.0, 6060.0, 6100.0], 'advice': 'Oil demand strong. Favorable for sellers.'},
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _currentData => _cropData[_selectedCrop]!;

  @override
  Widget build(BuildContext context) {
    final data = _currentData;
    final isUp = data['isUp'] as bool;

    return Scaffold(
      appBar: FarmAIAppBar(
        title: 'Market Prices',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business_rounded, color: AppTheme.primaryGreen),
            onPressed: () => context.push(AppRoutes.createMarketListing),
          ),
        ],
      ),
      body: Column(
        children: [
          // Crop Selector
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: _crops.length,
              itemBuilder: (_, i) {
                final crop = _crops[i];
                final selected = crop == _selectedCrop;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCrop = crop),
                  child: AnimatedContainer(
                    duration: 200.ms,
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.primaryGreen : AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      crop,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.grey[700],
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price Card
                  _PriceCard(crop: _selectedCrop, data: data)
                      .animate(key: ValueKey(_selectedCrop))
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.1),

                  const SizedBox(height: 20),

                  // Chart
                  _PriceChart(
                    history: (data['history'] as List).cast<double>(),
                    prediction: (data['prediction'] as List).cast<double>(),
                    isUp: isUp,
                  ).animate(delay: 200.ms).fadeIn(),

                  const SizedBox(height: 20),

                  // Advisory
                  _AdvisoryCard(advice: data['advice'] as String)
                      .animate(delay: 300.ms)
                      .fadeIn(),

                  const SizedBox(height: 20),

                  // All Crops Table
                  _AllCropsTable(crops: _cropData)
                      .animate(delay: 400.ms)
                      .fadeIn(),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  final String crop;
  final Map<String, dynamic> data;

  const _PriceCard({required this.crop, required this.data});

  @override
  Widget build(BuildContext context) {
    final isUp = data['isUp'] as bool;
    final changeColor = isUp ? AppTheme.primaryGreen : AppTheme.alertRed;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isUp
              ? [AppTheme.darkGreen, AppTheme.primaryGreen]
              : [const Color(0xFFC62828), const Color(0xFFE53935)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isUp ? AppTheme.primaryGreen : AppTheme.alertRed)
                .withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    crop,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    data['market'] as String,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${isUp ? "+" : ""}${data['change']}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Price',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${data['unit']?.toString().split('/').first}${(data['current'] as double).toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    data['unit'] as String,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '14-Day Forecast',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${data['unit']?.toString().split('/').first}${(data['predicted'] as double).toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isUp ? '↑ Expected Rise' : '↓ Expected Fall',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceChart extends StatelessWidget {
  final List<double> history;
  final List<double> prediction;
  final bool isUp;

  const _PriceChart({
    required this.history,
    required this.prediction,
    required this.isUp,
  });

  @override
  Widget build(BuildContext context) {
    final allPoints = [...history, ...prediction.skip(1)];
    final minY = allPoints.reduce((a, b) => a < b ? a : b) * 0.97;
    final maxY = allPoints.reduce((a, b) => a > b ? a : b) * 1.03;

    final historicalSpots = history
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    final predictedSpots = prediction
        .asMap()
        .entries
        .map((e) => FlSpot((history.length - 1 + e.key).toDouble(), e.value))
        .toList();

    final lineColor = isUp ? AppTheme.primaryGreen : AppTheme.alertRed;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Price Trend',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Spacer(),
              _LegendDot(color: lineColor, label: 'Actual'),
              const SizedBox(width: 12),
              _LegendDot(
                  color: lineColor.withOpacity(0.5), label: 'Predicted'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maxY - minY) / 4,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.grey.withOpacity(0.15),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (val, _) => Text(
                        '₹${val.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (val, _) {
                        final labels = ['-5w', '-4w', '-3w', '-2w', '-1w', 'Now', '+1w', '+2w', '+3w', '+4w'];
                        final idx = val.round();
                        if (idx >= 0 && idx < labels.length) {
                          return Text(
                            labels[idx],
                            style: TextStyle(fontSize: 9, color: Colors.grey[400]),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [
                  // Historical
                  LineChartBarData(
                    spots: historicalSpots,
                    isCurved: true,
                    color: lineColor,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          lineColor.withOpacity(0.15),
                          lineColor.withOpacity(0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Predicted
                  LineChartBarData(
                    spots: predictedSpots,
                    isCurved: true,
                    color: lineColor.withOpacity(0.5),
                    barWidth: 2,
                    dashArray: [6, 4],
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }
}

class _AdvisoryCard extends StatelessWidget {
  final String advice;
  const _AdvisoryCard({required this.advice});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.sunYellow.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.sunYellow.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.sunYellow.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.lightbulb_rounded,
              color: Color(0xFFFF8F00),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Market Advisory',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE65100),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  advice,
                  style: const TextStyle(fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AllCropsTable extends StatelessWidget {
  final Map<String, Map<String, dynamic>> crops;
  const _AllCropsTable({required this.crops});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Crops Overview',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        ...crops.entries.map((e) {
          final isUp = e.value['isUp'] as bool;
          return GestureDetector(
            onTap: () => context.push(AppRoutes.marketProductDetail),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.08),
                ),
              ),
              child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.grass_rounded,
                      size: 16, color: AppTheme.primaryGreen),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    e.key,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
                Text(
                  '${e.value['unit'].toString().split('/').first}${(e.value['current'] as double).toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color:
                        (isUp ? AppTheme.primaryGreen : AppTheme.alertRed)
                            .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${isUp ? "+" : ""}${e.value['change']}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isUp ? AppTheme.primaryGreen : AppTheme.alertRed,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
      ],
    );
  }
}
