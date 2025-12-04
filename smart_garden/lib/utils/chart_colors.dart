import 'package:flutter/material.dart';

class ChartColors {
  static Color getColorForChart(String chart) {
    switch (chart) {
      case 'temperatura':
        return const Color(0xFFFF6B6B);
      case 'humidadeAr':
        return const Color(0xFF4ECDC4);
      case 'humidadeSolo':
        return const Color(0xFF8B7355);
      case 'nivelAgua':
        return const Color(0xFF5C7CFA);
      case 'nivelLuz':
        return const Color(0xFFFFA94D);
      default:
        return const Color(0xFF4ECDC4);
    }
  }

  static IconData getIconForChart(String chart) {
    switch (chart) {
      case 'temperatura':
        return Icons.thermostat;
      case 'humidadeAr':
        return Icons.water_drop;
      case 'humidadeSolo':
        return Icons.grass;
      case 'nivelAgua':
        return Icons.opacity;
      case 'nivelLuz':
        return Icons.wb_sunny;
      default:
        return Icons.show_chart;
    }
  }
}