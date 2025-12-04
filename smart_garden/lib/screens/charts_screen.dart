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
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E27),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Gráficos',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            ChartColors.getColorForChart(_selectedChart),
          ),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Text(
          'Erro: $_error',
          style: const TextStyle(color: Colors.white70),
        ),
      );
    }

    if (_historyData.isEmpty) {
      return const Center(
        child: Text(
          'Sem dados disponíveis',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
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
        ],
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
