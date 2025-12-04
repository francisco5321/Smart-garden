import '../models/sensor_data.dart';
import '../models/sensor_limits.dart';

class ChartConfig {
  final String title;
  final double Function(SensorData) valueExtractor;
  final String unit;
  final double minLimit;
  final double maxLimit;
  final double? fixedMinY;
  final double? fixedMaxY;

  const ChartConfig({
    required this.title,
    required this.valueExtractor,
    required this.unit,
    required this.minLimit,
    required this.maxLimit,
    this.fixedMinY,
    this.fixedMaxY,
  });

  static ChartConfig getConfig(String chartType) {
    switch (chartType) {
      case 'temperatura':
        return ChartConfig(
          title: 'Temperatura do Ar',
          valueExtractor: (data) => data.temperaturaAr,
          unit: '°C',
          minLimit: SensorLimits.temperaturaArMin,
          maxLimit: SensorLimits.temperaturaArMax,
          fixedMinY: 0,
          fixedMaxY: 50,
        );
      case 'humidadeAr':
        return ChartConfig(
          title: 'Humidade do Ar',
          valueExtractor: (data) => data.humidadeAr,
          unit: '%',
          minLimit: SensorLimits.humidadeArMin,
          maxLimit: SensorLimits.humidadeArMax,
          fixedMinY: 0,
          fixedMaxY: 100,
        );
      case 'humidadeSolo':
        return ChartConfig(
          title: 'Humidade do Solo',
          valueExtractor: (data) => data.umidadeSolo,
          unit: '%',
          minLimit: SensorLimits.umidadeSoloMin,
          maxLimit: SensorLimits.umidadeSoloMax,
          fixedMinY: 0,
          fixedMaxY: 100,
        );
      case 'nivelAgua':
        return ChartConfig(
          title: 'Nível de Água',
          valueExtractor: (data) => data.nivelAgua,
          unit: '%',
          minLimit: SensorLimits.nivelAguaMin,
          maxLimit: SensorLimits.nivelAguaMax,
          fixedMinY: 0,
          fixedMaxY: 100,
        );
      case 'nivelLuz':
        return ChartConfig(
          title: 'Nível de Luz',
          valueExtractor: (data) => data.nivelLuz,
          unit: '%',
          minLimit: SensorLimits.nivelLuzMin,
          maxLimit: SensorLimits.nivelLuzMax,
          fixedMinY: 0,
          fixedMaxY: 100,
        );
      default:
        return ChartConfig(
          title: 'Temperatura do Ar',
          valueExtractor: (data) => data.temperaturaAr,
          unit: '°C',
          minLimit: SensorLimits.temperaturaArMin,
          maxLimit: SensorLimits.temperaturaArMax,
          fixedMinY: 0,
          fixedMaxY: 50,
        );
    }
  }
}