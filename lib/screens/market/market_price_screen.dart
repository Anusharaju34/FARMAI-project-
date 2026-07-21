import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../routes/app_router.dart';
import '../../services/market_service.dart';
import '../../widgets/common/common_widgets.dart';

class MarketPriceScreen extends StatefulWidget {
  const MarketPriceScreen({super.key});

  @override
  State<MarketPriceScreen> createState() => _MarketPriceScreenState();
}

class _MarketPriceScreenState extends State<MarketPriceScreen> {
  final MarketService _marketService = MarketService();

  StreamSubscription<Map<String, Map<String, dynamic>>>?
      _marketSubscription;

  Map<String, Map<String, dynamic>> _cropData = {};

  String? _selectedCrop;
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _cropData = Map<String, Map<String, dynamic>>.from(
      _marketService.currentMarketData,
    );

    if (_cropData.isNotEmpty) {
      _selectedCrop = _cropData.keys.first;
      _isLoading = false;
    }

    _marketSubscription =
        _marketService.marketDataStream.listen((updatedData) {
      if (!mounted) {
        return;
      }

      setState(() {
        _cropData =
            Map<String, Map<String, dynamic>>.from(updatedData);

        if (_cropData.isNotEmpty &&
            (_selectedCrop == null ||
                !_cropData.containsKey(_selectedCrop))) {
          _selectedCrop = _cropData.keys.first;
        }

        _isLoading = false;
        _isRefreshing = false;
        _errorMessage = _marketService.lastError;
      });
    });

    _loadMarketPrices();
  }

  Future<void> _loadMarketPrices() async {
    setState(() {
      _isLoading = _cropData.isEmpty;
      _errorMessage = null;
    });

    try {
      await _marketService.fetchLiveMarketPrices(
        state: 'Tamil Nadu',
        limit: 100,
      );

      if (!mounted) {
        return;
      }

      final data = _marketService.currentMarketData;

      setState(() {
        _cropData =
            Map<String, Map<String, dynamic>>.from(data);

        if (_cropData.isNotEmpty) {
          if (_selectedCrop == null ||
              !_cropData.containsKey(_selectedCrop)) {
            _selectedCrop = _cropData.keys.first;
          }
        }

        _isLoading = false;
        _errorMessage = null;
      });

      // Check for newly published government records every 15 minutes.
      _marketService.startRealtimeUpdates(
        state: 'Tamil Nadu',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = _cleanError(error);
      });
    }
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) {
      return;
    }

    setState(() {
      _isRefreshing = true;
      _errorMessage = null;
    });

    try {
      await _marketService.refresh(
        state: 'Tamil Nadu',
      );

      if (!mounted) {
        return;
      }

      final data = _marketService.currentMarketData;

      setState(() {
        _cropData =
            Map<String, Map<String, dynamic>>.from(data);

        if (_cropData.isNotEmpty &&
            (_selectedCrop == null ||
                !_cropData.containsKey(_selectedCrop))) {
          _selectedCrop = _cropData.keys.first;
        }

        _isRefreshing = false;
        _errorMessage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 18,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Latest government mandi prices loaded.',
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.primaryGreen,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isRefreshing = false;
        _errorMessage = _cleanError(error);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to refresh prices: ${_cleanError(error)}',
          ),
          backgroundColor: AppTheme.alertRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst('Exception: ', '')
        .trim();
  }

  Map<String, dynamic>? get _currentData {
    final crop = _selectedCrop;

    if (crop == null) {
      return null;
    }

    return _cropData[crop];
  }

  List<String> get _availableCrops {
    final crops = _cropData.keys.toList();

    crops.sort(
      (first, second) =>
          first.toLowerCase().compareTo(second.toLowerCase()),
    );

    return crops;
  }

  @override
  void dispose() {
    _marketSubscription?.cancel();
    _marketService.stopRealtimeUpdates();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FarmAIAppBar(
        title: 'Market Prices',
        actions: [
          IconButton(
            tooltip: 'Refresh prices',
            onPressed: _isRefreshing ? null : _handleRefresh,
            icon: _isRefreshing
                ? const SizedBox(
                    width: 19,
                    height: 19,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.primaryGreen,
                    ),
                  )
                : const Icon(
                    Icons.refresh_rounded,
                    color: AppTheme.primaryGreen,
                  ),
          ),
          IconButton(
            tooltip: 'Create market listing',
            icon: const Icon(
              Icons.add_business_rounded,
              color: AppTheme.primaryGreen,
            ),
            onPressed: () {
              context.push(AppRoutes.createMarketListing);
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _cropData.isEmpty) {
      return const _LoadingView();
    }

    if (_errorMessage != null && _cropData.isEmpty) {
      return _ErrorView(
        message: _errorMessage!,
        onRetry: _loadMarketPrices,
      );
    }

    if (_cropData.isEmpty) {
      return _EmptyView(
        onRetry: _loadMarketPrices,
      );
    }

    final data = _currentData;

    if (data == null) {
      return _EmptyView(
        onRetry: _loadMarketPrices,
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppTheme.primaryGreen,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          _LiveStatusTicker(
            lastUpdated: _marketService.lastUpdated,
            arrivalDate: _readString(data['arrivalDate']),
          ),

          if (_errorMessage != null)
            _InlineErrorBanner(
              message: _errorMessage!,
              onRetry: _handleRefresh,
            ),

          _CropSelector(
            crops: _availableCrops,
            selectedCrop: _selectedCrop,
            onSelected: (crop) {
              setState(() {
                _selectedCrop = crop;
              });
            },
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PriceCard(
                  crop: _selectedCrop ?? 'Commodity',
                  data: data,
                )
                    .animate(
                      key: ValueKey(
                        '${_selectedCrop}_${data['current']}',
                      ),
                    )
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.04),

                const SizedBox(height: 18),

                _PriceDetailsCard(data: data)
                    .animate(delay: 80.ms)
                    .fadeIn(),

                const SizedBox(height: 18),

                _PriceChart(
                  history: _readDoubleList(data['history']),
                  currentPrice: _readDouble(data['current']),
                )
                    .animate(delay: 120.ms)
                    .fadeIn(),

                const SizedBox(height: 18),

                _SourceCard(
                  source: _readString(
                    data['source'],
                    fallback: 'data.gov.in / AGMARKNET',
                  ),
                  advice: _readString(data['advice']),
                )
                    .animate(delay: 180.ms)
                    .fadeIn(),

                const SizedBox(height: 20),

                _AllCropsTable(
                  crops: _cropData,
                  selectedCrop: _selectedCrop,
                  onCropSelected: (crop) {
                    setState(() {
                      _selectedCrop = crop;
                    });
                  },
                )
                    .animate(delay: 220.ms)
                    .fadeIn(),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CropSelector extends StatelessWidget {
  final List<String> crops;
  final String? selectedCrop;
  final ValueChanged<String> onSelected;

  const _CropSelector({
    required this.crops,
    required this.selectedCrop,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        itemCount: crops.length,
        itemBuilder: (context, index) {
          final crop = crops[index];
          final selected = crop == selectedCrop;

          return GestureDetector(
            onTap: () => onSelected(crop),
            child: AnimatedContainer(
              duration: 200.ms,
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? AppTheme.primaryGreen
                    : AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? AppTheme.primaryGreen
                      : Colors.grey.withOpacity(0.15),
                ),
              ),
              child: Center(
                child: Text(
                  crop,
                  style: TextStyle(
                    color:
                        selected ? Colors.white : Colors.grey[700],
                    fontWeight: selected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LiveStatusTicker extends StatelessWidget {
  final DateTime? lastUpdated;
  final String arrivalDate;

  const _LiveStatusTicker({
    required this.lastUpdated,
    required this.arrivalDate,
  });

  @override
  Widget build(BuildContext context) {
    final updatedText = lastUpdated == null
        ? 'Waiting for update'
        : 'Fetched ${_formatTime(lastUpdated!)}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 9,
      ),
      color: AppTheme.primaryGreen.withOpacity(0.08),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppTheme.primaryGreen,
              shape: BoxShape.circle,
            ),
          )
              .animate(
                onPlay: (controller) {
                  controller.repeat(reverse: true);
                },
              )
              .scaleXY(
                begin: 0.8,
                end: 1.35,
                duration: 800.ms,
              ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'LATEST OFFICIAL MANDI DATA',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryGreen,
                letterSpacing: 0.4,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                updatedText,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[700],
                ),
              ),
              if (arrivalDate.isNotEmpty)
                Text(
                  'Arrival: $arrivalDate',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    final second = value.second.toString().padLeft(2, '0');

    return '$hour:$minute:$second';
  }
}

class _PriceCard extends StatelessWidget {
  final String crop;
  final Map<String, dynamic> data;

  const _PriceCard({
    required this.crop,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final current = _readDouble(data['current']);
    final minimum = _readDouble(data['minPrice']);
    final maximum = _readDouble(data['maxPrice']);
    final change = _readDouble(data['change']);
    final isUp = data['isUp'] == true;
    final market = _readString(
      data['market'],
      fallback: 'Market unavailable',
    );
    final district = _readString(data['district']);
    final state = _readString(data['state']);

    final locationParts = <String>[
      market,
      if (district.isNotEmpty) district,
      if (state.isNotEmpty) state,
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppTheme.darkGreen,
            AppTheme.primaryGreen,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      crop,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: Colors.white70,
                          size: 14,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            locationParts.join(', '),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      isUp
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${isUp && change > 0 ? '+' : ''}'
                      '${change.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            'Latest modal price',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '₹${current.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            'per quintal',
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _PriceRangeItem(
                  label: 'Minimum',
                  value: minimum,
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: Colors.white.withOpacity(0.2),
              ),
              Expanded(
                child: _PriceRangeItem(
                  label: 'Maximum',
                  value: maximum,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceRangeItem extends StatelessWidget {
  final String label;
  final double value;

  const _PriceRangeItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.75),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '₹${value.toStringAsFixed(0)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PriceDetailsCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _PriceDetailsCard({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final variety = _readString(
      data['variety'],
      fallback: 'Not specified',
    );
    final grade = _readString(
      data['grade'],
      fallback: 'Not specified',
    );
    final arrivalDate = _readString(
      data['arrivalDate'],
      fallback: 'Not available',
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outline
              .withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Market record details',
            style:
                Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _DetailItem(
                  icon: Icons.eco_rounded,
                  label: 'Variety',
                  value: variety,
                ),
              ),
              Expanded(
                child: _DetailItem(
                  icon: Icons.verified_rounded,
                  label: 'Grade',
                  value: grade,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _DetailItem(
            icon: Icons.calendar_month_rounded,
            label: 'Arrival date',
            value: arrivalDate,
          ),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: AppTheme.primaryGreen,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PriceChart extends StatelessWidget {
  final List<double> history;
  final double currentPrice;

  const _PriceChart({
    required this.history,
    required this.currentPrice,
  });

  @override
  Widget build(BuildContext context) {
    final safeHistory = history.isEmpty
        ? <double>[currentPrice]
        : List<double>.from(history);

    if (safeHistory.length == 1) {
      safeHistory.add(safeHistory.first);
    }

    final minimumValue = safeHistory.reduce(
      (first, second) => first < second ? first : second,
    );

    final maximumValue = safeHistory.reduce(
      (first, second) => first > second ? first : second,
    );

    final difference = maximumValue - minimumValue;
    final padding =
        difference == 0 ? maximumValue * 0.05 : difference * 0.2;

    final minY = (minimumValue - padding).clamp(
      0,
      double.infinity,
    );

    final maxY = maximumValue + padding;

    final spots = safeHistory
        .asMap()
        .entries
        .map(
          (entry) => FlSpot(
            entry.key.toDouble(),
            entry.value,
          ),
        )
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outline
              .withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price update trend',
            style:
                Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
          ),
          const SizedBox(height: 4),
          Text(
            'Trend from prices fetched during this session',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: minY.toDouble(),
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval:
                      (maxY - minY.toDouble()) / 4 == 0
                          ? 1
                          : (maxY - minY.toDouble()) / 4,
                  getDrawingHorizontalLine: (_) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.15),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 52,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '₹${value.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey[500],
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        if (value.round() == 0) {
                          return const Text(
                            'Previous',
                            style: TextStyle(fontSize: 9),
                          );
                        }

                        if (value.round() ==
                            safeHistory.length - 1) {
                          return const Text(
                            'Latest',
                            style: TextStyle(fontSize: 9),
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles:
                        SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles:
                        SideTitles(showTitles: false),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppTheme.primaryGreen,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryGreen
                              .withOpacity(0.18),
                          AppTheme.primaryGreen
                              .withOpacity(0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
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

class _SourceCard extends StatelessWidget {
  final String source;
  final String advice;

  const _SourceCard({
    required this.source,
    required this.advice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.sunYellow.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.sunYellow.withOpacity(0.3),
        ),
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
              Icons.verified_rounded,
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
                  'Official data source',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE65100),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  source,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (advice.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    advice,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
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
  final String? selectedCrop;
  final ValueChanged<String> onCropSelected;

  const _AllCropsTable({
    required this.crops,
    required this.selectedCrop,
    required this.onCropSelected,
  });

  @override
  Widget build(BuildContext context) {
    final sortedEntries = crops.entries.toList()
      ..sort(
        (first, second) => first.key
            .toLowerCase()
            .compareTo(second.key.toLowerCase()),
      );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available mandi prices',
          style:
              Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
        ),
        const SizedBox(height: 4),
        Text(
          '${sortedEntries.length} commodities returned by the API',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        ...sortedEntries.map((entry) {
          final crop = entry.key;
          final data = entry.value;
          final selected = crop == selectedCrop;
          final current = _readDouble(data['current']);
          final market = _readString(
            data['market'],
            fallback: 'Market unavailable',
          );

          return GestureDetector(
            onTap: () => onCropSelected(crop),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: selected
                    ? AppTheme.primaryGreen.withOpacity(0.07)
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected
                      ? AppTheme.primaryGreen.withOpacity(0.4)
                      : Theme.of(context)
                          .colorScheme
                          .outline
                          .withOpacity(0.08),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.grass_rounded,
                      size: 17,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          crop,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          market,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '₹${current.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : Icons.chevron_right_rounded,
                    size: 18,
                    color: selected
                        ? AppTheme.primaryGreen
                        : Colors.grey,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: AppTheme.primaryGreen,
            ),
            SizedBox(height: 16),
            Text(
              'Loading latest mandi prices...',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 52,
              color: AppTheme.alertRed,
            ),
            const SizedBox(height: 14),
            const Text(
              'Unable to load market prices',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final Future<void> Function() onRetry;

  const _EmptyView({
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 50,
              color: Colors.grey[500],
            ),
            const SizedBox(height: 14),
            const Text(
              'No mandi-price records found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try refreshing or remove the state filter '
              'temporarily in MarketService.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineErrorBanner extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _InlineErrorBanner({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      color: AppTheme.alertRed.withOpacity(0.08),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppTheme.alertRed,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.alertRed,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

String _readString(
  dynamic value, {
  String fallback = '',
}) {
  final text = value?.toString().trim() ?? '';

  return text.isEmpty ? fallback : text;
}

double _readDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(
        value?.toString().replaceAll(',', '').trim() ?? '',
      ) ??
      0.0;
}

List<double> _readDoubleList(dynamic value) {
  if (value is! List) {
    return [];
  }

  return value
      .map(_readDouble)
      .where((number) => number > 0)
      .toList();
}