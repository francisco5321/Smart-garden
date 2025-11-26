import 'package:flutter/material.dart';
import '../widgets/sensor_card.dart';
import '../services/mqtt_service.dart';
import '../models/sensor_data.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final MqttService _mqttService = MqttService();
  SensorData? _currentData;
  bool _isConnected = false;
  bool _isConnecting = true;
  String? _error;
  DateTime? _lastUpdate;

  @override
  void initState() {
    super.initState();
    print('🟢 MainScreen: initState chamado');
    _connectMqtt();
  }

  Future<void> _connectMqtt() async {
    setState(() {
      _isConnecting = true;
      _error = null;
    });

    try {
      print('🔵 MainScreen: Conectando ao MQTT...');
      await _mqttService.connect();
      
      setState(() {
        _isConnected = true;
        _isConnecting = false;
        _error = null;
      });

      print('✅ MainScreen: Conectado! Escutando dados...');

      // Escutar dados do MQTT
      _mqttService.sensorDataStream.listen(
        (data) {
          print('📊 MainScreen: Dados recebidos via MQTT');
          setState(() {
            _currentData = data;
            _lastUpdate = DateTime.now();
          });
        },
        onError: (error) {
          print('🔴 MainScreen: Erro no stream: $error');
          setState(() {
            _error = error.toString();
          });
        },
      );

      // Solicitar dados atuais imediatamente
      _mqttService.requestCurrentData();
      
    } catch (e) {
      print('🔴 MainScreen: Erro ao conectar: $e');
      setState(() {
        _error = e.toString();
        _isConnected = false;
        _isConnecting = false;
      });
    }
  }

  @override
  void dispose() {
    print('🔴 MainScreen: dispose chamado');
    _mqttService.disconnect();
    super.dispose();
  }

  String _getTimeSinceUpdate() {
    if (_lastUpdate == null) return 'Aguardando...';
    
    final difference = DateTime.now().difference(_lastUpdate!);
    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s atrás';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}min atrás';
    } else {
      return '${difference.inHours}h atrás';
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 MainScreen: build - connecting: $_isConnecting, connected: $_isConnected, hasData: ${_currentData != null}');
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F5),
      appBar: AppBar(
        title: const Text('Smart Garden', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        backgroundColor: const Color(0xFF2D6A4F),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                Icon(
                  _isConnected ? Icons.cloud_done : Icons.cloud_off,
                  color: _isConnected ? Colors.lightGreenAccent : Colors.redAccent,
                ),
                const SizedBox(width: 4),
                Text(
                  _isConnected ? 'Online' : 'Offline',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isConnecting
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF2D6A4F)),
                  SizedBox(height: 16),
                  Text('Conectando ao MQTT...', style: TextStyle(fontSize: 16)),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        const Text(
                          'Erro de Conexão',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14, color: Colors.red),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _connectMqtt,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reconectar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2D6A4F),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    _mqttService.requestCurrentData();
                  },
                  color: const Color(0xFF2D6A4F),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        // Header
                        Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2D6A4F),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                          ),
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                          child: Column(
                            children: [
                              const Icon(Icons.energy_savings_leaf, size: 48, color: Color(0xFF95D5B2)),
                              const SizedBox(height: 8),
                              const Text(
                                'Monitorização em Tempo Real',
                                style: TextStyle(fontSize: 18, color: Colors.white70, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'MQTT • ${_getTimeSinceUpdate()}',
                                style: const TextStyle(fontSize: 14, color: Colors.white54),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              SensorCard(
                                icon: Icons.thermostat,
                                iconColor: const Color(0xFFE63946),
                                title: 'Temperatura',
                                value: _currentData != null 
                                    ? '${_currentData!.temperaturaAr.toStringAsFixed(1)} °C'
                                    : '--',
                                gradientColors: const [Color(0xFFFFE5E5), Color(0xFFFFF0F0)],
                              ),
                              const SizedBox(height: 16),
                              SensorCard(
                                icon: Icons.water_drop,
                                iconColor: const Color(0xFF8B4513),
                                title: 'Humidade do Solo',
                                value: _currentData != null 
                                    ? '${_currentData!.umidadeSolo.toStringAsFixed(1)}%'
                                    : '--',
                                gradientColors: const [Color(0xFFE8D5C4), Color(0xFFF5EBE0)],
                              ),
                              const SizedBox(height: 16),
                              SensorCard(
                                icon: Icons.air,
                                iconColor: const Color(0xFF4A90E2),
                                title: 'Humidade do Ar',
                                value: _currentData != null 
                                    ? '${_currentData!.humidadeAr.toStringAsFixed(1)}%'
                                    : '--',
                                gradientColors: const [Color(0xFFE3F2FD), Color(0xFFF0F7FF)],
                              ),
                              const SizedBox(height: 16),
                              SensorCard(
                                icon: Icons.opacity,
                                iconColor: const Color(0xFF1976D2),
                                title: 'Nível de Água',
                                value: _currentData != null 
                                    ? '${_currentData!.nivelAgua.toStringAsFixed(1)}%'
                                    : '--',
                                gradientColors: const [Color(0xFFD6EAF8), Color(0xFFEBF5FB)],
                              ),
                              const SizedBox(height: 16),
                              SensorCard(
                                icon: Icons.wb_sunny,
                                iconColor: const Color(0xFFFFA726),
                                title: 'Nível de Luz',
                                value: _currentData != null 
                                    ? '${_currentData!.nivelLuz.toStringAsFixed(1)}%'
                                    : '--',
                                gradientColors: const [Color(0xFFFFF8E1), Color(0xFFFFFDF7)],
                              ),
                              const SizedBox(height: 24),

                              // Status Card
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: _isConnected 
                                        ? const [Color(0xFF52B788), Color(0xFF74C69D)]
                                        : [Colors.grey.shade400, Colors.grey.shade500],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (_isConnected 
                                          ? const Color(0xFF52B788)
                                          : Colors.grey.shade400).withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        _isConnected ? Icons.check_circle : Icons.cloud_off,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _isConnected 
                                                ? 'Sistema Operacional'
                                                : 'Sistema Offline',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _isConnected 
                                                ? 'Recebendo dados via MQTT'
                                                : 'Verifique a conexão',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
