import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sensor_data.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api/garden';
  
  // Obter dados atuais dos sensores
  Future<SensorData> getCurrentSensorData() async {
    final response = await http.get(Uri.parse('$baseUrl/sensor/current'));
    
    if (response.statusCode == 200) {
      return SensorData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Falha ao carregar dados');
    }
  }
  
  // Obter histórico de dados
  Future<List<SensorData>> getHistoricalData({int limit = 100, int offset = 0}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/sensor/history?limit=$limit&offset=$offset')
    );
    
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => SensorData.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar histórico');
    }
  }
  
  // Criar nova leitura
  Future<SensorData> createSensorReading(SensorData data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sensor'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data.toJson()),
    );
    
    if (response.statusCode == 201) {
      return SensorData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Falha ao criar leitura');
    }
  }
}