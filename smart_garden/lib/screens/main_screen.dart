import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/sensor_data.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final DatabaseService _dbService = DatabaseService();
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
      print('🟡 MainScreen: Chamando Database...');
      final data = await _dbService.getCurrentSensorData();
      
      print('✅ MainScreen: Dados recebidos!');
      setState(() {
        _currentData = data;
        _isLoading = false;
      });
    } catch (e, stack) {
      print('🔴 MainScreen: Erro capturado!');
      print('❌ Erro: $e');
      print('📍 StackTrace: $stack');
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
      appBar: AppBar(
        title: const Text('Smart Garden'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCurrentData,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text('Erro: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCurrentData,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (_currentData == null) {
      return const Center(child: Text('Nenhum dado disponível'));
    }

    return RefreshIndicator(
      onRefresh: _loadCurrentData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCard('Temperatura', '${_currentData!.temperaturaAr}°C', Icons.thermostat),
          _buildCard('Humidade do Ar', '${_currentData!.humidadeAr}%', Icons.water_drop),
          _buildCard('Humidade do Solo', '${_currentData!.umidadeSolo}%', Icons.grass),
          _buildCard('Nível de Água', '${_currentData!.nivelAgua}', Icons.water),
          _buildCard('Nível de Luz', '${_currentData!.nivelLuz}', Icons.light_mode),
          const SizedBox(height: 8),
          Text(
            'Última atualização: ${_currentData!.dataRegisto}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, size: 40),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}