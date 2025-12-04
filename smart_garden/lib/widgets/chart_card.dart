import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/sensor_data.dart';

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

    final chartMinY = fixedMinY ?? (dataMin - (dataMax - dataMin) * 0.2).clamp(0.0, double.infinity).toDouble();
    final chartMaxY = fixedMaxY ?? (dataMax + (dataMax - dataMin) * 0.2).toDouble();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(hasWarning),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: const Color(0xFF2D3436).withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          _buildCurrentValue(currentValue),
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
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const Spacer(),
        if (hasWarning)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B6B).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_rounded,
                  size: 16,
                  color: const Color(0xFFFF6B6B),
                ),
                const SizedBox(width: 6),
                Text(
                  'Crítico',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFF6B6B),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCurrentValue(double currentValue) {
    return Text(
      '${currentValue.toStringAsFixed(1)}$unit',
      style: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: color,
        height: 1.2,
      ),
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
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE9ECEF),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: const Color(0xFF2D3436).withValues(alpha: 0.5),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${value.toStringAsFixed(1)}$unit',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3436),
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
                color: const Color(0xFFE9ECEF),
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
                      color: const Color(0xFF2D3436).withValues(alpha: 0.4),
                      fontWeight: FontWeight.w500,
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
              tooltipBgColor: Colors.white,
              tooltipRoundedRadius: 12,
              tooltipPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              tooltipBorder: BorderSide(
                color: const Color(0xFFE9ECEF),
                width: 1,
              ),
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
                        style: TextStyle(
                          color: const Color(0xFF2D3436).withValues(alpha: 0.6),
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
                  color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
                  strokeWidth: 2,
                  dashArray: [8, 4],
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 8),
                    style: TextStyle(
                      color: const Color(0xFFFF6B6B),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    labelResolver: (line) => 'Min',
                  ),
                ),
              if (maxLimit >= chartMinY && maxLimit <= chartMaxY)
                HorizontalLine(
                  y: maxLimit,
                  color: const Color(0xFFFFA94D).withValues(alpha: 0.3),
                  strokeWidth: 2,
                  dashArray: [8, 4],
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 8),
                    style: TextStyle(
                      color: const Color(0xFFFFA94D),
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
                    color.withValues(alpha: 0.2),
                    color.withValues(alpha: 0.0),
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