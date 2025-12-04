import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/database_service.dart';
import '../models/sensor_data.dart';
import '../models/sensor_limits.dart';
import 'package:intl/intl.dart';

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Gráficos',
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 24,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
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
              'A carregar gráficos',
              style: TextStyle(
                fontSize: 13,
                color: const Color(0xFF2D3436).withOpacity(0.5),
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
              Icons.error_outline,
              size: 56,
              color: Colors.red.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Erro: $_error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      );
    }

    if (_historyData.isEmpty) {
      return const Center(child: Text('Sem dados disponíveis'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPeriodSelector(),
          const SizedBox(height: 20),
          _buildChartCard(
            'Temperatura do Ar',
            const Color(0xFFFF6B6B),
            (data) => data.temperaturaAr,
            '°C',
            SensorLimits.temperaturaArMin,
            SensorLimits.temperaturaArMax,
          ),
          const SizedBox(height: 16),
          _buildChartCard(
            'Humidade do Ar',
            const Color(0xFF4ECDC4),
            (data) => data.humidadeAr,
            '%',
            SensorLimits.humidadeArMin,
            SensorLimits.humidadeArMax,
          ),
          const SizedBox(height: 16),
          _buildChartCard(
            'Humidade do Solo',
            const Color(0xFF8B7355),
            (data) => data.umidadeSolo,
            '%',
            SensorLimits.umidadeSoloMin,
            SensorLimits.umidadeSoloMax,
          ),
          const SizedBox(height: 16),
          _buildChartCard(
            'Nível de Água',
            const Color(0xFF5C7CFA),
            (data) => data.nivelAgua,
            '',
            SensorLimits.nivelAguaMin,
            SensorLimits.nivelAguaMax,
          ),
          const SizedBox(height: 16),
          _buildChartCard(
            'Nível de Luz',
            const Color(0xFFFFA94D),
            (data) => data.nivelLuz,
            '',
            SensorLimits.nivelLuzMin,
            SensorLimits.nivelLuzMax,
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: ['1h', '6h', '24h', '7d'].map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = period;
                });
                _loadHistoryData();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF4A7C59) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChartCard(
    String title,
    Color color,
    double Function(SensorData) valueExtractor,
    String unit,
    double minLimit,
    double maxLimit,
  ) {
    final spots = _historyData.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        valueExtractor(entry.value),
      );
    }).toList();

    // Verificar se há valores em estado crítico
    final hasWarning = _historyData.any((data) {
      final value = valueExtractor(data);
      return value < minLimit || value > maxLimit;
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: hasWarning ? Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 2,
        ) : null,
        boxShadow: [
          BoxShadow(
            color: hasWarning 
              ? Colors.red.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3436),
                  ),
                ),
              ),
              if (hasWarning)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        size: 16,
                        color: Colors.red.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Crítico',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildLegendItem('Mín', minLimit, unit, Colors.red.withOpacity(0.6)),
              const SizedBox(width: 16),
              _buildLegendItem('Máx', maxLimit, unit, Colors.orange.withOpacity(0.6)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}$unit',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: _historyData.length > 10 
                        ? _historyData.length / 5 
                        : 1,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= _historyData.length) return const Text('');
                        final data = _historyData[value.toInt()];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            DateFormat('HH:mm').format(data.dataRegisto),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    // Linha mínima crítica
                    HorizontalLine(
                      y: minLimit,
                      color: Colors.red.withOpacity(0.3),
                      strokeWidth: 2,
                      dashArray: [5, 5],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        padding: const EdgeInsets.only(right: 5, bottom: 5),
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                        labelResolver: (line) => 'Mín',
                      ),
                    ),
                    // Linha máxima crítica
                    HorizontalLine(
                      y: maxLimit,
                      color: Colors.orange.withOpacity(0.3),
                      strokeWidth: 2,
                      dashArray: [5, 5],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.bottomRight,
                        padding: const EdgeInsets.only(right: 5, top: 5),
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                        labelResolver: (line) => 'Máx',
                      ),
                    ),
                  ],
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        final value = spot.y;
                        final isCritical = value < minLimit || value > maxLimit;
                        return FlDotCirclePainter(
                          radius: isCritical ? 4 : 2,
                          color: isCritical ? Colors.red : color,
                          strokeWidth: isCritical ? 2 : 0,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withOpacity(0.1),
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

  Widget _buildLegendItem(String label, double value, String unit, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 2,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: ${value.toInt()}$unit',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}