import 'package:postgres/postgres.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/sensor_data.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Connection? _connection;

  Future<void> initialize() async {
    try {
      print('🔌 Conectando ao PostgreSQL...');
      
      _connection = await Connection.open(
        Endpoint(
          host: dotenv.env['DB_HOST']!,
          database: dotenv.env['DB_NAME']!,
          username: dotenv.env['DB_USER']!,
          password: dotenv.env['DB_PASSWORD']!,
          port: int.parse(dotenv.env['DB_PORT'] ?? '5432'),
        ),
        settings: const ConnectionSettings(sslMode: SslMode.disable),
      );
      
      print('✅ Conectado ao PostgreSQL!');
    } catch (e) {
      print('❌ Erro ao conectar: $e');
      rethrow;
    }
  }

  // Função auxiliar para converter valores para double
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Future<SensorData?> getCurrentSensorData() async {
    try {
      final result = await _connection!.execute(
        Sql.named('SELECT * FROM public.dados_sensores ORDER BY data_registo DESC LIMIT 1'),
      );

      if (result.isNotEmpty) {
        final row = result.first.toColumnMap();
        print('🔍 Dados recebidos: $row'); // Debug
        
        return SensorData(
          id: row['id'] as int?,
          dataRegisto: row['data_registo'] as DateTime,
          temperaturaAr: _toDouble(row['temperatura_ar']),
          humidadeAr: _toDouble(row['humidade_ar']),
          nivelAgua: _toDouble(row['nivel_agua']),
          umidadeSolo: _toDouble(row['umidade_solo']),
          nivelLuz: _toDouble(row['nivel_luz']),
        );
      }
      return null;
    } catch (e) {
      print('❌ Erro ao buscar dados: $e');
      rethrow;
    }
  }

  Future<List<SensorData>> getHistoricalData({int limit = 100}) async {
    try {
      final result = await _connection!.execute(
        Sql.named('SELECT * FROM public.dados_sensores ORDER BY data_registo DESC LIMIT @limit'),
        parameters: {'limit': limit},
      );

      return result.map((row) {
        final map = row.toColumnMap();
        return SensorData(
          id: map['id'] as int?,
          dataRegisto: map['data_registo'] as DateTime,
          temperaturaAr: _toDouble(map['temperatura_ar']),
          humidadeAr: _toDouble(map['humidade_ar']),
          nivelAgua: _toDouble(map['nivel_agua']),
          umidadeSolo: _toDouble(map['umidade_solo']),
          nivelLuz: _toDouble(map['nivel_luz']),
        );
      }).toList();
    } catch (e) {
      print('❌ Erro ao buscar histórico: $e');
      rethrow;
    }
  }

  Future<void> close() async {
    await _connection?.close();
  }
}