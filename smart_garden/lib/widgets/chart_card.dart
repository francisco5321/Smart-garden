import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/sensor_data.dart';
import '../utils/chart_colors.dart';

class ChartCard extends StatelessWidget {
  final String title;
  final Color color;
  final List<SensorData> historyData;
  final double Function(SensorData) valueExtractor;
  final String unit;
  final double minLimit;
  final double maxLimit;
  final double? fixedMinY;
  final double? fixedMaxY;
  final IconData icon;

  const ChartCard({
    super.key,
    required this.title,
    required this.color,
    required this.historyData,
    required this.valueExtractor,
    required this.unit,
    required this.minLimit,
    required this.maxLimit,
    this.fixedMinY,
    this.fixedMaxY,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final spots = historyData.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        valueExtractor(entry.value),
      );
    }).toList();

    final currentValue = historyData.isNotEmpty
        ? valueExtractor(historyData.last)
        : 0.0;
    final hasWarning = currentValue < minLimit || currentValue > maxLimit;

    double dataMin = currentValue;
    double dataMax = currentValue;
    if (historyData.isNotEmpty) {
      dataMin = historyData.map(valueExtractor).reduce((a, b) => a < b ? a : b);
      dataMax = historyData.map(valueExtractor).reduce((a, b) => a > b ? a : b);
    }

    // Remove percentChange calculation
    final chartMinY = fixedMinY ?? (dataMin - (dataMax - dataMin) * 0.2).clamp(0.0, double.infinity).toDouble();
    final chartMaxY = fixedMaxY ?? (dataMax + (dataMax - dataMin) * 0.2).toDouble();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(hasWarning),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          _buildCurrentValue(currentValue, 0), // percentChange não é mais usado
          const SizedBox(height: 16),
          _buildStatistics(dataMin, dataMax),
          const SizedBox(height: 20),
          _buildChart(spots, chartMinY, chartMaxY),
        ],
      ),
    );
  }

  Widget _buildHeader(bool hasWarning) {
    return Row(
      children: [
        Icon(icon, color: color, size: 28),
        const Spacer(),
        if (hasWarning)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_rounded,
                  size: 14,
                  color: Colors.red.shade300,
                ),
                const SizedBox(width: 4),
                Text(
                  'Crítico',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade300,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCurrentValue(double currentValue, double percentChange) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${currentValue.toStringAsFixed(1)}$unit',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: color,
            height: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics(double dataMin, double dataMax) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('Mínimo', dataMin),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('Máximo', dataMax),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, double value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${value.toStringAsFixed(1)}$unit',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(List<FlSpot> spots, double chartMinY, double chartMaxY) {
    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          minY: chartMinY,
          maxY: chartMaxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (chartMaxY - chartMinY) / 4,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.white.withOpacity(0.05),
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
                reservedSize: 45,
                interval: (chartMaxY - chartMinY) / 4,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: const Color(0xFF2A2F4A),
              tooltipRoundedRadius: 8,
              tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((spot) {
                  final data = historyData[spot.x.toInt()];
                  return LineTooltipItem(
                    '${spot.y.toStringAsFixed(1)}$unit\n',
                    TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    children: [
                      TextSpan(
                        text: DateFormat('HH:mm').format(data.dataRegisto),
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
          ),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              if (minLimit >= chartMinY && minLimit <= chartMaxY)
                HorizontalLine(
                  y: minLimit,
                  color: Colors.red.withOpacity(0.3),
                  strokeWidth: 2,
                  dashArray: [8, 4],
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 8),
                    style: TextStyle(
                      color: Colors.red.shade300,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    labelResolver: (line) => 'Min',
                  ),
                ),
              if (maxLimit >= chartMinY && maxLimit <= chartMaxY)
                HorizontalLine(
                  y: maxLimit,
                  color: Colors.orange.withOpacity(0.3),
                  strokeWidth: 2,
                  dashArray: [8, 4],
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 8),
                    style: TextStyle(
                      color: Colors.orange.shade300,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    labelResolver: (line) => 'Max',
                  ),
                ),
            ],
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.35,
              preventCurveOverShooting: true,
              preventCurveOvershootingThreshold: 2.0,
              color: color,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.2),
                    color.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}