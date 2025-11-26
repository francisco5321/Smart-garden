import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sensor_data.dart';

class ApiService {
  // Para emulador Android use 10.0.2.2
  // Para navegador web use localhost
  // Para dispositivo físico use o IP da sua máquina
  static const String baseUrl = 'http://localhost:3000/api/garden';
  
  Future<SensorData> getCurrentSensorData() async {
    print('🌐 ApiService: Iniciando requisição');
    print('📍 URL: $baseUrl/sensor/current');
    
    try {
      print('⏳ ApiService: Enviando GET request...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/sensor/current'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⏰ ApiService: Timeout após 10 segundos');
          throw Exception('Timeout: Servidor não respondeu');
        },
      );
      
      print('📥 ApiService: Resposta recebida');
      print('📊 Status Code: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');
      print('🔑 Response Headers: ${response.headers}');
      
      if (response.statusCode == 200) {
        print('✅ ApiService: Status 200 OK');
        
        try {
          final Map<String, dynamic> data = json.decode(response.body);
          print('🔍 JSON decodificado: $data');
          
          final sensorData = SensorData.fromJson(data);
          print('✨ SensorData criado com sucesso');
          return sensorData;
        } catch (e, stack) {
          print('🔴 Erro ao parsear JSON: $e');
          print('📍 Stack: $stack');
          throw Exception('Erro ao processar dados: $e');
        }
      } else {
        print('❌ ApiService: Status ${response.statusCode}');
        throw Exception('Erro HTTP ${response.statusCode}: ${response.body}');
      }
    } on http.ClientException catch (e, stack) {
      print('🔴 ClientException: $e');
      print('📍 Stack: $stack');
      throw Exception('Erro de conexão: Verifique se o backend está rodando');
    } catch (e, stack) {
      print('🔴 Erro genérico: $e');
      print('📍 Stack: $stack');
      throw Exception('Falha ao carregar dados: $e');
    }
  }
  
  Future<List<SensorData>> getHistoricalData({int limit = 100, int offset = 0}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sensor/history?limit=$limit&offset=$offset'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => SensorData.fromJson(item)).toList();
      } else {
        throw Exception('Erro HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Falha ao carregar histórico: $e');
    }
  }
}