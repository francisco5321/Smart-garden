import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/sensor_data.dart';
import '../widgets/chart_selector.dart';
import '../widgets/period_selector.dart';
import '../widgets/chart_card.dart';
import '../utils/chart_colors.dart';
import '../utils/chart_config.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<SensorData> _historyData = [];
  bool _isLoading = true;
  String? _error;
  String _selectedPeriod = '24h';
  String _selectedChart = 'temperatura';

  @override
  void initState() {
    super.initState();
    _loadHistoryData();
  }

  Future<void> _loadHistoryData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final endDate = DateTime.now();
      final startDate = _getStartDate(endDate);

      final data = await _dbService.getSensorHistory(
        startDate: startDate,
        endDate: endDate,
      );

      if (mounted) {
        setState(() {
          _historyData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  DateTime _getStartDate(DateTime endDate) {
    switch (_selectedPeriod) {
      case '1h':
        return endDate.subtract(const Duration(hours: 1));
      case '6h':
        return endDate.subtract(const Duration(hours: 6));
      case '24h':
        return endDate.subtract(const Duration(hours: 24));
      case '7d':
        return endDate.subtract(const Duration(days: 7));
      default:
        return endDate.subtract(const Duration(hours: 24));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 242, 245, 242),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF4A7C59),
                const Color(0xFF5D9B6D),
              ],
            ),
          ),
        ),
        toolbarHeight: 80,
        leadingWidth: 56,
        leading: Center(
          child: Container(
            width: 40,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.show_chart_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Gráficos',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 24,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.refresh_rounded,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () => _loadHistoryData(),
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color(0xFF4A7C59),
                ),
                strokeWidth: 2.5,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'A carregar dados',
              style: TextStyle(
                fontSize: 13,
                color: const Color(0xFF2D3436).withValues(alpha: 0.5),
                fontWeight: FontWeight.w400,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: const Color(0xFF2D3436).withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Text(
              'Erro: $_error',
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF2D3436).withValues(alpha: 0.5),
                fontWeight: FontWeight.w400,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _loadHistoryData(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tentar novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A7C59),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_historyData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 56,
              color: const Color(0xFF2D3436).withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Text(
              'Sem dados disponíveis',
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF2D3436).withValues(alpha: 0.5),
                fontWeight: FontWeight.w400,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadHistoryData(),
      color: const Color(0xFF4A7C59),
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ChartSelector(
              selectedChart: _selectedChart,
              onChartSelected: (chart) {
                setState(() {
                  _selectedChart = chart;
                });
              },
            ),
            const SizedBox(height: 20),
            _buildSelectedChart(),
            const SizedBox(height: 20),
            PeriodSelector(
              selectedPeriod: _selectedPeriod,
              accentColor: ChartColors.getColorForChart(_selectedChart),
              onPeriodSelected: (period) {
                setState(() {
                  _selectedPeriod = period;
                });
                _loadHistoryData();
              },
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedChart() {
    final config = ChartConfig.getConfig(_selectedChart);
    final color = ChartColors.getColorForChart(_selectedChart);
    final icon = ChartColors.getIconForChart(_selectedChart);

    return ChartCard(
      title: config.title,
      color: color,
      historyData: _historyData,
      valueExtractor: config.valueExtractor,
      unit: config.unit,
      minLimit: config.minLimit,
      maxLimit: config.maxLimit,
      fixedMinY: config.fixedMinY,
      fixedMaxY: config.fixedMaxY,
      icon: icon,
    );
  }
}
