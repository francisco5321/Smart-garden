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
      id: json['id'],
      dataRegisto: DateTime.parse(json['data_registo']),
      temperaturaAr: json['temperatura_ar'].toDouble(),
      humidadeAr: json['humidade_ar'].toDouble(),
      nivelAgua: json['nivel_agua'].toDouble(),
      umidadeSolo: json['umidade_solo'].toDouble(),
      nivelLuz: json['nivel_luz'].toDouble(),
    );
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
}