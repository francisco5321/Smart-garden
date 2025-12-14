import 'package:postgres/postgres.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/sensor_data.dart';
import 'dart:math' as math;

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

      print(' Conectado ao PostgreSQL!');
    } catch (e) {
      print(' Erro ao conectar: $e');
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
        Sql.named(
          'SELECT * FROM public.dados_sensores ORDER BY data_registo DESC LIMIT 1',
        ),
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
      print(' Erro ao buscar dados: $e');
      rethrow;
    }
  }

  Future<List<SensorData>> getHistoricalData({int limit = 100}) async {
    try {
      final result = await _connection!.execute(
        Sql.named(
          'SELECT * FROM public.dados_sensores ORDER BY data_registo DESC LIMIT @limit',
        ),
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
      print(' Erro ao buscar histórico: $e');
      rethrow;
    }
  }

  Future<List<SensorData>> getSensorHistory({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Calcular diferença em horas para decidir estratégia de agregação
      final hours = endDate.difference(startDate).inHours;

      // Se o período for grande, usar agregação
      if (hours > 24) {
        return _getAggregatedSensorHistory(
          startDate: startDate,
          endDate: endDate,
          intervalMinutes: _getOptimalInterval(hours),
        );
      }

      // Para períodos pequenos (<=24h), usar downsampling simples
      return _getDownsampledSensorHistory(
        startDate: startDate,
        endDate: endDate,
        maxPoints: 500, // Máximo de pontos para garantir performance
      );
    } catch (e) {
      print(' Erro ao buscar histórico por período: $e');
      rethrow;
    }
  }

  // Determina o intervalo ideal de agregação baseado no período
  int _getOptimalInterval(int hours) {
    if (hours <= 6) return 1; // 1 minuto para <= 6h
    if (hours <= 24) return 5; // 5 minutos para <= 24h
    if (hours <= 72) return 15; // 15 minutos para <= 3 dias
    if (hours <= 168) return 30; // 30 minutos para <= 7 dias
    if (hours <= 720) return 120; // 2 horas para <= 30 dias
    return 360; // 6 horas para > 30 dias
  }

  // Query com agregação por intervalo de tempo (muito eficiente para grandes volumes)
  Future<List<SensorData>> _getAggregatedSensorHistory({
    required DateTime startDate,
    required DateTime endDate,
    required int intervalMinutes,
  }) async {
    try {
      print('📊 Agregando dados com intervalo de $intervalMinutes minutos');

      final result = await _connection!.execute(
        Sql.named('''
          SELECT 
            date_trunc('hour', data_registo) + 
            INTERVAL '1 minute' * (FLOOR(EXTRACT(MINUTE FROM data_registo) / @interval) * @interval) as data_registo,
            AVG(temperatura_ar) as temperatura_ar,
            AVG(humidade_ar) as humidade_ar,
            AVG(nivel_agua) as nivel_agua,
            AVG(umidade_solo) as umidade_solo,
            AVG(nivel_luz) as nivel_luz,
            COUNT(*) as num_registros
          FROM public.dados_sensores
          WHERE data_registo >= @startDate AND data_registo <= @endDate
          GROUP BY date_trunc('hour', data_registo) + 
            INTERVAL '1 minute' * (FLOOR(EXTRACT(MINUTE FROM data_registo) / @interval) * @interval)
          ORDER BY data_registo ASC
        '''),
        parameters: {
          'startDate': startDate,
          'endDate': endDate,
          'interval': intervalMinutes,
        },
      );

      final dataList = result.map((row) {
        final map = row.toColumnMap();
        return SensorData(
          id: null, // IDs não são relevantes em dados agregados
          dataRegisto: map['data_registo'] as DateTime,
          temperaturaAr: _toDouble(map['temperatura_ar']),
          humidadeAr: _toDouble(map['humidade_ar']),
          nivelAgua: _toDouble(map['nivel_agua']),
          umidadeSolo: _toDouble(map['umidade_solo']),
          nivelLuz: _toDouble(map['nivel_luz']),
        );
      }).toList();

      print(' Retornados ${dataList.length} pontos agregados');
      return dataList;
    } catch (e) {
      print(' Erro ao buscar histórico agregado: $e');
      rethrow;
    }
  }

  // Query com downsampling simples (para períodos curtos)
  Future<List<SensorData>> _getDownsampledSensorHistory({
    required DateTime startDate,
    required DateTime endDate,
    required int maxPoints,
  }) async {
    try {
      // Primeiro, contar quantos registros existem
      final countResult = await _connection!.execute(
        Sql.named('''
          SELECT COUNT(*) as total
          FROM public.dados_sensores
          WHERE data_registo >= @startDate AND data_registo <= @endDate
        '''),
        parameters: {'startDate': startDate, 'endDate': endDate},
      );

      final total = (countResult.first.toColumnMap()['total'] as int?) ?? 0;
      print(' Total de registros no período: $total');

      // Se temos menos pontos que o máximo, retornar todos
      if (total <= maxPoints) {
        final result = await _connection!.execute(
          Sql.named('''
            SELECT * FROM public.dados_sensores
            WHERE data_registo >= @startDate AND data_registo <= @endDate
            ORDER BY data_registo ASC
          '''),
          parameters: {'startDate': startDate, 'endDate': endDate},
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
      }

      // Caso contrário, fazer downsampling pegando 1 a cada N registros
      final step = (total / maxPoints).ceil();
      print(' Aplicando downsampling: pegando 1 a cada $step registros');

      final result = await _connection!.execute(
        Sql.named('''
          SELECT * FROM (
            SELECT *, ROW_NUMBER() OVER (ORDER BY data_registo ASC) as rn
            FROM public.dados_sensores
            WHERE data_registo >= @startDate AND data_registo <= @endDate
          ) t
          WHERE t.rn % @step = 1
          ORDER BY data_registo ASC
        '''),
        parameters: {'startDate': startDate, 'endDate': endDate, 'step': step},
      );

      final dataList = result.map((row) {
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

      print(' Retornados ${dataList.length} pontos com downsampling');
      return dataList;
    } catch (e) {
      print(' Erro ao buscar histórico com downsampling: $e');
      rethrow;
    }
  }

  Future<void> close() async {
    await _connection?.close();
  }
}
