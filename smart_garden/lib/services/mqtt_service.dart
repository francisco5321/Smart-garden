import 'dart:async';
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/sensor_data.dart';

class MqttService {
  MqttServerClient? _client;
  
  // StreamControllers para broadcasts
  final _connectionController = StreamController<bool>.broadcast();
  final _sensorDataController = StreamController<SensorData>.broadcast();

  // Getters para os streams
  Stream<bool> get connectionStatus => _connectionController.stream;
  Stream<SensorData> get sensorDataStream => _sensorDataController.stream;

  Future<void> connect() async {
    final broker = dotenv.env['MQTT_BROKER'] ?? 'localhost';
    final port = int.parse(dotenv.env['MQTT_PORT'] ?? '1883');
    final clientId = dotenv.env['MQTT_CLIENT_ID'] ?? 'smart_garden_app';
    final topic = dotenv.env['MQTT_TOPIC_SENSORS'] ?? 'smart_garden/sensors';

    print('🔌 MQTT: Broker: $broker');
    print('🔌 MQTT: Port: $port');
    print('🔌 MQTT: Client ID: $clientId');
    print('🔌 MQTT: Conectando ao broker $broker:$port');

    _client = MqttServerClient(broker, clientId);
    _client!.port = port;
    _client!.keepAlivePeriod = 60;
    _client!.logging(on: true);
    _client!.onConnected = _onConnected;
    _client!.onDisconnected = _onDisconnected;
    _client!.onSubscribed = _onSubscribed;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    
    _client!.connectionMessage = connMessage;

    try {
      await _client!.connect();
      
      if (_client!.connectionStatus?.state == MqttConnectionState.connected) {
        print('✅ MQTT: Conectado com sucesso!');
        _connectionController.add(true);
        
        print('📥 MQTT: Inscrevendo no tópico $topic');
        _client!.subscribe(topic, MqttQos.atLeastOnce);
        
        _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
          final MqttPublishMessage message = c[0].payload as MqttPublishMessage;
          final payload = MqttPublishPayload.bytesToStringAsString(message.payload.message);
          
          print('📨 MQTT: Mensagem recebida: $payload');
          
          try {
            final data = SensorData.fromJson(json.decode(payload));
            _sensorDataController.add(data);
            print('✅ MQTT: Dados parseados e enviados ao stream');
          } catch (e) {
            print('❌ MQTT: Erro ao parsear dados: $e');
          }
        });
      } else {
        print('🔴 MQTT: Falha na conexão');
        _connectionController.add(false);
      }
    } catch (e) {
      print('🔴 MQTT: Erro ao conectar: $e');
      _connectionController.add(false);
      rethrow;
    }
  }

  void _onConnected() {
    print('✅ MQTT: Callback onConnected');
    _connectionController.add(true);
  }

  void _onDisconnected() {
    print('⚠️ MQTT: Desconectado');
    _connectionController.add(false);
  }

  void _onSubscribed(String topic) {
    print('✅ MQTT: Inscrito no tópico: $topic');
  }

  void disconnect() {
    print('🔌 MQTT: Desconectando...');
    _client?.disconnect();
    _connectionController.close();
    _sensorDataController.close();
  }

  void publish(String topic, String message) {
    if (_client?.connectionStatus?.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      _client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
      print('📤 MQTT: Mensagem publicada em $topic: $message');
    } else {
      print('❌ MQTT: Não conectado, não foi possível publicar');
    }
  }
}