import 'package:flutter/material.dart';
import '../widgets/sensor_card.dart';
import '../services/api_service.dart';
import '../models/sensor_data.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final ApiService _apiService = ApiService();
  SensorData? _currentData;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    print('🟢 MainScreen: initState chamado');
    _loadCurrentData();
  }

  Future<void> _loadCurrentData() async {
    print('🔵 MainScreen: Iniciando _loadCurrentData');
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('🟡 MainScreen: Chamando API...');
      final data = await _apiService.getCurrentSensorData();
      print('🟢 MainScreen: Dados recebidos com sucesso!');
      print('📊 Dados: $data');
      
      setState(() {
        _currentData = data;
        _isLoading = false;
      });
      print('✅ MainScreen: Estado atualizado com sucesso');
    } catch (e, stackTrace) {
      print('🔴 MainScreen: Erro capturado!');
      print('❌ Erro: $e');
      print('📍 StackTrace: $stackTrace');
      
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 MainScreen: build chamado - isLoading: $_isLoading, error: $_error, hasData: ${_currentData != null}');
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F5),
      appBar: AppBar(
        title: const Text('Smart Garden', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        backgroundColor: const Color(0xFF2D6A4F),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              print('🔄 MainScreen: Botão refresh pressionado');
              _loadCurrentData();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2D6A4F)))
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
                          'Erro ao carregar dados',
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
                          onPressed: () {
                            print('🔄 MainScreen: Botão Tentar Novamente pressionado');
                            _loadCurrentData();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tentar Novamente'),
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
                  onRefresh: _loadCurrentData,
                  color: const Color(0xFF2D6A4F),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        // Header decorativo
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
                            children: const [
                              Icon(Icons.energy_savings_leaf, size: 48, color: Color(0xFF95D5B2)),
                              SizedBox(height: 8),
                              Text(
                                'Monitorização em Tempo Real',
                                style: TextStyle(fontSize: 18, color: Colors.white70, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
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

                              // System Status Card
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: _currentData != null 
                                        ? const [Color(0xFF52B788), Color(0xFF74C69D)]
                                        : [Colors.grey.shade400, Colors.grey.shade500],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (_currentData != null 
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
                                        _currentData != null ? Icons.check_circle : Icons.sync,
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
                                            _currentData != null 
                                                ? 'Sistema Operacional'
                                                : 'A Carregar...',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _currentData != null 
                                                ? 'Última atualização: ${_currentData!.dataRegisto.toString().split('.')[0]}'
                                                : 'A aguardar dados dos sensores',
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
