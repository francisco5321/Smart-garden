import 'package:flutter/material.dart';
import 'dart:async';
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
  
  StreamSubscription<bool>? _connectionSubscription;
  StreamSubscription<SensorData>? _dataSubscription;

  @override
  void initState() {
    super.initState();
    print('🟢 MainScreen: initState chamado');
    _connectMqtt();
  }

  Future<void> _connectMqtt() async {
    print('🔵 MainScreen: Conectando ao MQTT...');
    setState(() {
      _isConnecting = true;
      _isConnected = false;
    });

    try {
      // Cancelar subscriptions anteriores se existirem
      await _connectionSubscription?.cancel();
      await _dataSubscription?.cancel();

      // Conectar ao MQTT
      await _mqttService.connect();

      // Aguardar um momento para garantir que a conexão foi estabelecida
      await Future.delayed(const Duration(milliseconds: 500));

      // Escutar status de conexão
      _connectionSubscription = _mqttService.connectionStatus.listen((status) {
        if (mounted) {
          print('📡 MainScreen: Status de conexão atualizado: $status');
          setState(() {
            _isConnected = status;
            if (status) {
              _isConnecting = false;
            }
          });
        }
      });

      // Escutar dados dos sensores
      _dataSubscription = _mqttService.sensorDataStream.listen((data) {
        if (mounted) {
          print('📊 MainScreen: Dados recebidos: ${data.temperaturaAr}°C');
          setState(() {
            _currentData = data;
            // Garantir que não está mais em estado de loading
            if (_isConnecting) {
              _isConnecting = false;
              _isConnected = true;
            }
          });
        }
      });

      // Forçar atualização do estado após conexão
      if (mounted) {
        setState(() {
          _isConnected = true;
          _isConnecting = false;
        });
      }
      
    } catch (e) {
      print('🔴 MainScreen: Erro ao conectar: $e');
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _isConnected = false;
        });
      }
    }
  }

  @override
  void dispose() {
    print('🔴 MainScreen: dispose chamado');
    _connectionSubscription?.cancel();
    _dataSubscription?.cancel();
    _mqttService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 MainScreen: build - connecting: $_isConnecting, connected: $_isConnected, hasData: ${_currentData != null}');
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: _isConnecting
            ? _buildLoadingView()
            : !_isConnected
                ? _buildErrorView()
                : _currentData == null
                    ? _buildNoDataView()
                    : _buildDataView(),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          Text(
            'Conectando...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Sem conexão',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Verifique sua conexão e tente novamente',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _connectMqtt,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tentar Novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hourglass_empty_rounded,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'Aguardando dados...',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataView() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildSensorGrid(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.eco_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Smart Garden',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1B5E20),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sistema ativo',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSensorGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSensorCard(
                icon: Icons.thermostat_rounded,
                title: 'Temperatura',
                value: '${_currentData!.temperaturaAr.toStringAsFixed(1)}°C',
                color: const Color(0xFFFF6B6B),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSensorCard(
                icon: Icons.water_drop_rounded,
                title: 'Humidade',
                value: '${_currentData!.humidadeAr.toStringAsFixed(0)}%',
                color: const Color(0xFF4ECDC4),
                gradient: const LinearGradient(
                  colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSensorCard(
                icon: Icons.opacity_rounded,
                title: 'Nível Água',
                value: '${_currentData!.nivelAgua.toStringAsFixed(0)}%',
                color: const Color(0xFF4A90E2),
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSensorCard(
                icon: Icons.grass_rounded,
                title: 'Solo',
                value: '${_currentData!.umidadeSolo.toStringAsFixed(0)}%',
                color: const Color(0xFF8D6E63),
                gradient: const LinearGradient(
                  colors: [Color(0xFF8D6E63), Color(0xFF6D4C41)],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSensorCard(
          icon: Icons.wb_sunny_rounded,
          title: 'Luminosidade',
          value: '${_currentData!.nivelLuz.toStringAsFixed(0)}%',
          color: const Color(0xFFFFA726),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFA726), Color(0xFFFFB74D)],
          ),
          isWide: true,
        ),
      ],
    );
  }

  Widget _buildSensorCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Gradient gradient,
    bool isWide = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Colors.white.withOpacity(0.9),
                size: 24,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Agora',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }
}
