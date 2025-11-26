class SensorData {
  final int? id;
  final DateTime dataRegisto;
  final double temperaturaAr;
  final double humidadeAr;
  final double nivelAgua;
  final double umidadeSolo;
  final double nivelLuz;

  SensorData({
    this.id,
    required this.dataRegisto,
    required this.temperaturaAr,
    required this.humidadeAr,
    required this.nivelAgua,
    required this.umidadeSolo,
    required this.nivelLuz,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()),
      dataRegisto: DateTime.parse(json['data_registo']),
      temperaturaAr: _parseDouble(json['temperatura_ar']),
      humidadeAr: _parseDouble(json['humidade_ar']),
      nivelAgua: _parseDouble(json['nivel_agua']),
      umidadeSolo: _parseDouble(json['umidade_solo']),
      nivelLuz: _parseDouble(json['nivel_luz']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'temperatura_ar': temperaturaAr,
      'humidade_ar': humidadeAr,
      'nivel_agua': nivelAgua,
      'umidade_solo': umidadeSolo,
      'nivel_luz': nivelLuz,
    };
  }

  @override
  String toString() {
    return 'SensorData(id: $id, temp: $temperaturaAr°C, humidade_ar: $humidadeAr%, nivel_agua: $nivelAgua%, umidade_solo: $umidadeSolo%, luz: $nivelLuz%)';
  }
}