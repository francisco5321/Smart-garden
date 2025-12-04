import 'package:flutter/material.dart';
import '../utils/chart_colors.dart';

class ChartSelector extends StatelessWidget {
  final String selectedChart;
  final Function(String) onChartSelected;

  const ChartSelector({
    super.key,
    required this.selectedChart,
    required this.onChartSelected,
  });

  static const Map<String, Map<String, dynamic>> charts = {
    'temperatura': {'label': 'Temperatura', 'icon': Icons.thermostat_rounded},
    'humidadeAr': {'label': 'Humidade Ar', 'icon': Icons.water_drop_rounded},
    'humidadeSolo': {'label': 'Humidade Solo', 'icon': Icons.grass_rounded},
    'nivelAgua': {'label': 'Nível Água', 'icon': Icons.opacity_rounded},
    'nivelLuz': {'label': 'Nível Luz', 'icon': Icons.wb_sunny_rounded},
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: charts.entries.map((entry) {
          final isSelected = selectedChart == entry.key;
          final color = ChartColors.getColorForChart(entry.key);

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => onChartSelected(entry.key),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? color : const Color(0xFFE9ECEF),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      entry.value['icon'] as IconData,
                      size: 20,
                      color: isSelected ? color : const Color(0xFF2D3436).withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      entry.value['label'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        color: isSelected ? color : const Color(0xFF2D3436).withValues(alpha: 0.7),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}