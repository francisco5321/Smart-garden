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
    'temperatura': {'label': 'Temperatura', 'icon': Icons.thermostat},
    'humidadeAr': {'label': 'Humidade Ar', 'icon': Icons.water_drop},
    'humidadeSolo': {'label': 'Humidade Solo', 'icon': Icons.grass},
    'nivelAgua': {'label': 'Nível Água', 'icon': Icons.opacity},
    'nivelLuz': {'label': 'Nível Luz', 'icon': Icons.wb_sunny},
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withOpacity(0.2)
                      : const Color(0xFF1A1F3A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? color : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      entry.value['icon'] as IconData,
                      size: 18,
                      color: isSelected ? color : Colors.white60,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      entry.value['label'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        color: isSelected ? Colors.white : Colors.white60,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
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