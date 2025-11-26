import 'dart:async';
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/sensor_data.dart';

class MqttService {
  late MqttServerClient client;
  final _messageController = StreamController<SensorData>.broadcast();
  
  Stream<SensorData> get sensorDataStream => _messageController.stream;
  
  String get broker {
    if (!dotenv.isInitialized) {
      print('⚠️ dotenv não inicializado, usando padrão');
      return 'broker.hivemq.com';
    }
    return dotenv.env['MQTT_BROKER'] ?? 'broker.hivemq.com';
  }
  
  int get port {
    if (!dotenv.isInitialized) {
      print('⚠️ dotenv não inicializado, usando padrão');
      return 1883;
    }
    return int.parse(dotenv.env['MQTT_PORT'] ?? '1883');
  }
  
  String get clientId {
    if (!dotenv.isInitialized) {
      print('⚠️ dotenv não inicializado, usando padrão');
      return 'smart_garden_app';
    }
    return dotenv.env['MQTT_CLIENT_ID'] ?? 'smart_garden_app';
  }
  
  String get sensorsTopic {
    if (!dotenv.isInitialized) {
      return 'smart_garden/sensors';
    }
    return dotenv.env['MQTT_TOPIC_SENSORS'] ?? 'smart_garden/sensors';
  }
  
  String get controlTopic {
    if (!dotenv.isInitialized) {
      return 'smart_garden/control';
    }
    return dotenv.env['MQTT_TOPIC_CONTROL'] ?? 'smart_garden/control';
  }

  Future<void> connect() async {
    print('🔌 MQTT: Broker: $broker');
    print('🔌 MQTT: Port: $port');
    print('🔌 MQTT: Client ID: $clientId');
    
    client = MqttServerClient(broker, clientId);
    client.port = port;
    client.keepAlivePeriod = 60;
    client.logging(on: true);
    client.onConnected = _onConnected;
    client.onDisconnected = _onDisconnected;
    client.onSubscribed = _onSubscribed;
    
    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    
    client.connectionMessage = connMessage;

    try {
      print('🔌 MQTT: Conectando ao broker $broker:$port');
      await client.connect();
    } catch (e) {
      print('🔴 MQTT: Erro ao conectar: $e');
      client.disconnect();
      rethrow;
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('✅ MQTT: Conectado com sucesso!');
      _subscribeToTopics();
    } else {
      print('🔴 MQTT: Falha na conexão');
      client.disconnect();
      throw Exception('Falha na conexão MQTT');
    }
  }

  void _subscribeToTopics() {
    print('📥 MQTT: Inscrevendo no tópico $sensorsTopic');
    client.subscribe(sensorsTopic, MqttQos.atLeastOnce);
    
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      final recMessage = messages[0].payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(recMessage.payload.message);
      
      print('📨 MQTT: Mensagem recebida: $payload');
      
      try {
        final Map<String, dynamic> data = json.decode(payload);
        final sensorData = SensorData.fromJson(data);
        _messageController.add(sensorData);
      } catch (e) {
        print('🔴 MQTT: Erro ao processar mensagem: $e');
      }
    });
  }

  void requestCurrentData() {
    final builder = MqttClientPayloadBuilder();
    builder.addString('GET_CURRENT');
    
    print('📤 MQTT: Solicitando dados atuais');
    client.publishMessage('smart_garden/request', MqttQos.atLeastOnce, builder.payload!);
  }

  void publishControl(String command, dynamic value) {
    final payload = json.encode({
      'command': command,
      'value': value,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    final builder = MqttClientPayloadBuilder();
    builder.addString(payload);
    
    print('📤 MQTT: Publicando em $controlTopic: $payload');
    client.publishMessage(controlTopic, MqttQos.atLeastOnce, builder.payload!);
  }

  void _onConnected() {
    print('✅ MQTT: Callback onConnected');
  }

  void _onDisconnected() {
    print('⚠️ MQTT: Desconectado');
  }

  void _onSubscribed(String topic) {
    print('✅ MQTT: Inscrito no tópico: $topic');
  }

  void disconnect() {
    print('🔌 MQTT: Desconectando...');
    client.disconnect();
    _messageController.close();
  }
}