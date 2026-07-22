import 'dart:async';
import 'dart:math';
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
  StreamSubscription<Map<String, Map<String, dynamic>>>? _marketSubscription;
  Map<String, Map<String, dynamic>> _cropData = {};

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String? _selectedCrop;
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cropData = Map<String, Map<String, dynamic>>.from(_marketService.currentMarketData);

    if (_cropData.isNotEmpty) {
      _selectedCrop = _cropData.keys.first;
      _isLoading = false;
    }

    _marketSubscription = _marketService.marketDataStream.listen((updatedData) {
      if (!mounted) return;
      setState(() {
        _cropData = Map<String, Map<String, dynamic>>.from(updatedData);
        if (_cropData.isNotEmpty && (_selectedCrop == null || !_cropData.containsKey(_selectedCrop))) {
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
      await _marketService.fetchLiveMarketPrices(state: 'Tamil Nadu', limit: 100);
      if (!mounted) return;
      final data = _marketService.currentMarketData;
      setState(() {
        _cropData = Map<String, Map<String, dynamic>>.from(data);
        if (_cropData.isNotEmpty) {
          if (_selectedCrop == null || !_cropData.containsKey(_selectedCrop)) {
            _selectedCrop = _cropData.keys.first;
          }
        }
        _isLoading = false;
        _errorMessage = null;
      });
      _marketService.startRealtimeUpdates(state: 'Tamil Nadu');
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = _cleanError(error);
      });
    }
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;
    setState(() {
      _isRefreshing = true;
      _errorMessage = null;
    });

    try {
      await _marketService.refresh(state: 'Tamil Nadu');
      if (!mounted) return;
      final data = _marketService.currentMarketData;
      setState(() {
        _cropData = Map<String, Map<String, dynamic>>.from(data);
        if (_cropData.isNotEmpty && (_selectedCrop == null || !_cropData.containsKey(_selectedCrop))) {
          _selectedCrop = _cropData.keys.first;
        }
        _isRefreshing = false;
        _errorMessage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Expanded(child: Text('Latest government mandi prices loaded.')),
            ],
          ),
          backgroundColor: AppTheme.primaryGreen,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isRefreshing = false;
        _errorMessage = _cleanError(error);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to refresh prices: ${_cleanError(error)}'),
          backgroundColor: AppTheme.alertRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '').trim();
  }

  Map<String, dynamic>? get _currentData {
    final crop = _selectedCrop;
    if (crop == null) return null;
    return _cropData[crop];
  }

  List<String> get _availableCrops {
    var crops = _cropData.keys.toList();

    // Category filter
    if (_selectedCategory != 'All') {
      crops = crops.where((crop) {
        final cat = _getCropCategory(crop);
        return cat == _selectedCategory;
      }).toList();
    }

    // Search filter
    if (_searchQuery.trim().isNotEmpty) {
      crops = crops
          .where((crop) => crop.toLowerCase().contains(_searchQuery.trim().toLowerCase()))
          .toList();
    }

    crops.sort((first, second) => first.toLowerCase().compareTo(second.toLowerCase()));
    return crops;
  }

  String _getCropCategory(String crop) {
    final lower = crop.toLowerCase();
    if (lower.contains('rice') || lower.contains('wheat') || lower.contains('maize') || lower.contains('grain')) {
      return 'Grains';
    } else if (lower.contains('tomato') || lower.contains('onion') || lower.contains('potato') || lower.contains('vegetable')) {
      return 'Vegetables';
    }
    return 'Others';
  }

  @override
  void dispose() {
    _searchController.dispose();
    _marketSubscription?.cancel();
    _marketService.stopRealtimeUpdates();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
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
                : const Icon(Icons.refresh_rounded, color: AppTheme.primaryGreen),
          ),
          IconButton(
            tooltip: 'Create market listing',
            icon: const Icon(Icons.add_business_rounded, color: AppTheme.primaryGreen),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading && _cropData.isEmpty) {
      return const _LoadingView();
    }
    if (_errorMessage != null && _cropData.isEmpty) {
      return _ErrorView(message: _errorMessage!, onRetry: _loadMarketPrices);
    }
    if (_cropData.isEmpty) {
      return _EmptyView(onRetry: _loadMarketPrices);
    }

    final data = _currentData;
    if (data == null) {
      return _EmptyView(onRetry: _loadMarketPrices);
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppTheme.primaryGreen,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          _LiveStatusTicker(
            lastUpdated: _marketService.lastUpdated,
            arrivalDate: _readString(data['arrivalDate']),
          ),
          if (_errorMessage != null)
            _InlineErrorBanner(message: _errorMessage!, onRetry: _handleRefresh),

          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search commodity name...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryGreen),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark ? AppTheme.surfaceDark : Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                    width: 1.2,
                  ),
                ),
              ),
            ),
          ),

          // Filter Category Chips
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              children: ['All', 'Grains', 'Vegetables', 'Others'].map((cat) {
                final selected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: selected,
                    onSelected: (val) => setState(() => _selectedCategory = cat),
                    checkmarkColor: Colors.white,
                    selectedColor: AppTheme.primaryGreen,
                    backgroundColor: isDark ? AppTheme.surfaceDark : Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: selected ? AppTheme.primaryGreen : Colors.transparent),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Horizontal Crop Selector
          _CropSelector(
            crops: _availableCrops,
            selectedCrop: _selectedCrop,
            onSelected: (crop) => setState(() => _selectedCrop = crop),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PriceCard(
                  crop: _selectedCrop ?? 'Commodity',
                  data: data,
                ).animate(key: ValueKey('${_selectedCrop}_${data['current']}')).fadeIn(duration: 300.ms).slideY(begin: 0.04),

                const SizedBox(height: 18),
                _PriceBreakdownCard(
                  currentPrice: _readDouble(data['current']),
                ).animate(delay: 50.ms).fadeIn(),

                const SizedBox(height: 18),
                _PriceDetailsCard(data: data).animate(delay: 80.ms).fadeIn(),

                const SizedBox(height: 18),
                _PriceChart(
                  history: _readDoubleList(data['history']),
                  currentPrice: _readDouble(data['current']),
                ).animate(delay: 120.ms).fadeIn(),

                const SizedBox(height: 18),
                _SourceCard(
                  source: _readString(data['source'], fallback: 'data.gov.in / AGMARKNET'),
                  advice: _readString(data['advice']),
                ).animate(delay: 180.ms).fadeIn(),

                const SizedBox(height: 24),
                _AllCropsTable(
                  crops: _cropData,
                  selectedCrop: _selectedCrop,
                  onCropSelected: (crop) => setState(() => _selectedCrop = crop),
                ).animate(delay: 220.ms).fadeIn(),

                const SizedBox(height: 100),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 56,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: crops.length,
        itemBuilder: (context, index) {
          final crop = crops[index];
          final selected = crop == selectedCrop;

          return GestureDetector(
            onTap: () => onSelected(crop),
            child: AnimatedContainer(
              duration: 200.ms,
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? AppTheme.primaryGreen : (isDark ? AppTheme.cardDark : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? AppTheme.primaryGreen : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Text(
                  crop,
                  style: TextStyle(
                    color: selected ? Colors.white : (isDark ? Colors.white70 : Colors.grey[800]),
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final updatedText = lastUpdated == null ? 'Waiting for update' : 'Fetched ${_formatTime(lastUpdated!)}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: isDark ? AppTheme.cardDark.withOpacity(0.4) : AppTheme.primaryGreen.withOpacity(0.06),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppTheme.primaryGreen,
              shape: BoxShape.circle,
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(begin: 0.8, end: 1.35, duration: 800.ms),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'LATEST OFFICIAL MANDI DATA',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryGreen,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                updatedText,
                style: TextStyle(fontSize: 10, color: isDark ? Colors.white70 : Colors.grey[700], fontWeight: FontWeight.w500),
              ),
              if (arrivalDate.isNotEmpty)
                Text(
                  'Arrival: $arrivalDate',
                  style: TextStyle(fontSize: 9, color: isDark ? Colors.white38 : Colors.grey[500]),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatTime(DateTime value) {
    return '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}:${value.second.toString().padLeft(2, '0')}';
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
    final market = _readString(data['market'], fallback: 'Mandi');
    final district = _readString(data['district']);
    final state = _readString(data['state']);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryGreen, Color(0xFF1B5E20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
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
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_rounded, color: Colors.white70, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '$market, $district, $state',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
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
                      '${isUp && change > 0 ? '+' : ''}${change.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'MOST COMMON MARKET PRICE',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '₹${current.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.0,
            ),
          ),
          Text(
            'per quintal (100 kg)',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _PriceRangeItem(label: 'LOWEST PRICE TODAY', value: minimum),
              ),
              Container(width: 1, height: 36, color: Colors.white.withOpacity(0.15)),
              Expanded(
                child: _PriceRangeItem(label: 'HIGHEST PRICE TODAY', value: maximum),
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

  const _PriceRangeItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '₹${value.toStringAsFixed(0)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _PriceDetailsCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _PriceDetailsCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final variety = _readString(data['variety'], fallback: 'Not specified');
    final grade = _readString(data['grade'], fallback: 'Not specified');
    final arrivalDate = _readString(data['arrivalDate'], fallback: 'Not available');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Market Record Details',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _DetailItem(icon: Icons.eco_rounded, label: 'Variety', value: variety),
              ),
              Expanded(
                child: _DetailItem(icon: Icons.verified_rounded, label: 'Grade', value: grade),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _DetailItem(icon: Icons.calendar_month_rounded, label: 'Arrival Date', value: arrivalDate),
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
        Icon(icon, size: 20, color: AppTheme.primaryGreen),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final safeHistory = history.isEmpty ? <double>[currentPrice] : List<double>.from(history);

    if (safeHistory.length == 1) {
      safeHistory.add(safeHistory.first);
    }

    final minimumValue = safeHistory.reduce((a, b) => a < b ? a : b);
    final maximumValue = safeHistory.reduce((a, b) => a > b ? a : b);
    final difference = maximumValue - minimumValue;
    final padding = difference == 0 ? maximumValue * 0.05 : difference * 0.2;

    final minY = (minimumValue - padding).clamp(0.0, double.infinity);
    final maxY = maximumValue + padding;

    final spots = safeHistory.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Price Update Trend',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const SizedBox(height: 2),
          Text(
            'Historical trend for the active mandi session',
            style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maxY - minY) / 4 == 0 ? 1 : (maxY - minY) / 4,
                  getDrawingHorizontalLine: (_) => FlLine(color: isDark ? Colors.white10 : Colors.grey[150]!, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      getTitlesWidget: (v, m) => Text(
                        '₹${v.toStringAsFixed(0)}',
                        style: TextStyle(fontSize: 9, color: Colors.grey[500], fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (v, m) {
                        if (v.round() == 0) return const Text('Prev', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600));
                        if (v.round() == safeHistory.length - 1) return const Text('Latest', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600));
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                        colors: [AppTheme.primaryGreen.withOpacity(0.18), AppTheme.primaryGreen.withOpacity(0)],
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

  const _SourceCard({required this.source, required this.advice});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : const Color(0xFFFFF9C4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppTheme.borderDark : const Color(0xFFFBC02D).withOpacity(0.3), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFBC02D).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.verified_user_rounded, color: Color(0xFFF57F17), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Agmarknet Mandi Source',
                  style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFF57F17), fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  source,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                if (advice.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    advice,
                    style: const TextStyle(fontSize: 12, height: 1.4, fontWeight: FontWeight.w500),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sortedEntries = crops.entries.toList()
      ..sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Mandi Prices',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          '${sortedEntries.length} commodities loaded in memory',
          style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 14),
        ...sortedEntries.map((e) {
          final crop = e.key;
          final data = e.value;
          final selected = crop == selectedCrop;
          final current = _readDouble(data['current']);
          final market = _readString(data['market'], fallback: 'Mandi');

          return GestureDetector(
            onTap: () => onCropSelected(crop),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: selected ? AppTheme.primaryGreen.withOpacity(0.08) : (isDark ? AppTheme.cardDark : Colors.white),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? AppTheme.primaryGreen : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.grass_rounded, size: 18, color: AppTheme.primaryGreen),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          crop,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        Text(
                          market,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '₹${current.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    selected ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
                    size: 18,
                    color: selected ? AppTheme.primaryGreen : Colors.grey,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppTheme.primaryGreen),
          const SizedBox(height: 16),
          Text('Loading latest mandi prices...', style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 54, color: AppTheme.alertRed),
            const SizedBox(height: 16),
            const Text('Unable to load market prices', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[550])),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final Future<void> Function() onRetry;
  const _EmptyView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('No mandi price records found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('Check API key configuration or try refreshing.', textAlign: TextAlign.center),
            const SizedBox(height: 20),
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

  const _InlineErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppTheme.alertRed.withOpacity(0.08),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppTheme.alertRed, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12, color: AppTheme.alertRed, fontWeight: FontWeight.w500),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

String _readString(dynamic value, {String fallback = ''}) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

double _readDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString().replaceAll(',', '').trim() ?? '') ?? 0.0;
}

List<double> _readDoubleList(dynamic value) {
  if (value is! List) return [];
  return value.map(_readDouble).where((n) => n > 0).toList();
}

class _PriceBreakdownCard extends StatelessWidget {
  final double currentPrice;
  const _PriceBreakdownCard({required this.currentPrice});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pricePerKg = currentPrice / 100;
    final pricePer50kg = currentPrice / 2;
    final pricePer75kg = currentPrice * 0.75;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calculate_rounded, color: AppTheme.primaryGreen, size: 20),
              const SizedBox(width: 8),
              const Text(
                "Farmer's Price Breakdown",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Understand prices in common local bag & weight metrics',
            style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _BreakdownItem(
                  label: '1 kg Price',
                  value: '₹${pricePerKg.toStringAsFixed(1)}',
                  icon: Icons.scale_rounded,
                ),
              ),
              Expanded(
                child: _BreakdownItem(
                  label: '50 kg Bag',
                  value: '₹${pricePer50kg.toStringAsFixed(0)}',
                  icon: Icons.shopping_bag_outlined,
                ),
              ),
              Expanded(
                child: _BreakdownItem(
                  label: '75 kg Bag',
                  value: '₹${pricePer75kg.toStringAsFixed(0)}',
                  icon: Icons.shopping_bag_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BreakdownItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _BreakdownItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryGreen, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}