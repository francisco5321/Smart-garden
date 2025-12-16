import 'package:flutter/material.dart';
import 'dart:async';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../models/sensor_data.dart';
import '../widgets/sensor_card.dart';
import '../widgets/last_update_widget.dart';
import '../widgets/error_state_widget.dart';
import 'charts_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final DatabaseService _dbService = DatabaseService();
  final NotificationService _notificationService = NotificationService();
  SensorData? _currentData;
  bool _isLoading = false;
  String? _error;
  Timer? _pollingTimer;
  static const Duration _pollingInterval = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadCurrentData();
    _startPolling();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(_pollingInterval, (timer) {
      _loadCurrentData(showLoading: false);
    });
  }

  Future<void> _loadCurrentData({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final data = await _dbService.getCurrentSensorData();
      
      if (mounted) {
        setState(() {
          _currentData = data;
          _isLoading = false;
          _error = null;
        });

        // Verificar valores críticos e enviar notificação
        if (data != null) {
          await _notificationService.checkSensorValues(data);
        }
      }
    } catch (e, stack) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 242, 245, 242),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF4A7C59),
                const Color(0xFF5D9B6D),
              ],
            ),
          ),
        ),
        toolbarHeight: 80,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.eco_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Smart Garden',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 24,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.show_chart_rounded,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChartsScreen(),
                  ),
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.refresh_rounded,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () => _loadCurrentData(),
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color(0xFF4A7C59)
                ),
                strokeWidth: 2.5,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'A carregar',
              style: TextStyle(
                fontSize: 13,
                color: const Color(0xFF2D3436).withValues(alpha: 0.5),
                fontWeight: FontWeight.w400,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return ErrorStateWidget(
        errorMessage: _error!,
        onRetry: () => _loadCurrentData(),
      );
    }

    if (_currentData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 56,
              color: const Color(0xFF2D3436).withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum dado disponível',
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF2D3436).withValues(alpha: 0.5),
                fontWeight: FontWeight.w400,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadCurrentData(),
      color: const Color(0xFF4A7C59),
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SensorCard(
              title: 'Temperatura do Ar',
              value: '${_currentData!.temperaturaAr.toStringAsFixed(1)}°C',
              icon: Icons.thermostat_rounded,
              color: const Color(0xFFFF6B6B),
            ),
            const SizedBox(height: 14),
            SensorCard(
              title: 'Humidade do Ar',
              value: '${_currentData!.humidadeAr.toStringAsFixed(1)}%',
              icon: Icons.water_drop_rounded,
              color: const Color(0xFF4ECDC4),
            ),
            const SizedBox(height: 14),
            SensorCard(
              title: 'Humidade do Solo',
              value: '${_currentData!.umidadeSolo.toStringAsFixed(1)}%',
              icon: Icons.grass_rounded,
              color: const Color(0xFF8B7355),
            ),
            const SizedBox(height: 14),
            SensorCard(
              title: 'Nível de Água',
              value: '${_currentData!.nivelAgua.toStringAsFixed(1)}%',
              icon: Icons.opacity_rounded,
              color: const Color(0xFF5C7CFA),
            ),
            const SizedBox(height: 14),
            SensorCard(
              title: 'Nível de Luz',
              value: '${_currentData!.nivelLuz.toStringAsFixed(1)}%',
              icon: Icons.wb_sunny_rounded,
              color: const Color(0xFFFFA94D),
            ),
            const SizedBox(height: 28),
            LastUpdateWidget(dateTime: _currentData!.dataRegisto),
          ],
        ),
      ),
    );
  }
}