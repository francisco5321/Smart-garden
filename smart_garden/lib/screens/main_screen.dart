import 'package:flutter/material.dart';
import '../widgets/sensor_card.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F5),
      appBar: AppBar(
        title: const Text('Smart Garden', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        backgroundColor: const Color(0xFF2D6A4F),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header decorativo
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF2D6A4F),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
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
                  const SensorCard(
                    icon: Icons.thermostat,
                    iconColor: Color(0xFFE63946),
                    title: 'Temperatura',
                    value: '24.5 °C',
                    gradientColors: [Color(0xFFFFE5E5), Color(0xFFFFF0F0)],
                  ),
                  const SizedBox(height: 16),
                  const SensorCard(
                    icon: Icons.water_drop,
                    iconColor: Color(0xFF8B4513),
                    title: 'Humidade do Solo',
                    value: '68%',
                    gradientColors: [Color(0xFFE8D5C4), Color(0xFFF5EBE0)],
                  ),
                  const SizedBox(height: 16),
                  const SensorCard(
                    icon: Icons.air,
                    iconColor: Color(0xFF4A90E2),
                    title: 'Humidade do Ar',
                    value: '20%',
                    gradientColors: [Color(0xFFE3F2FD), Color(0xFFF0F7FF)],
                  ),
                  const SizedBox(height: 16),
                  const SensorCard(
                    icon: Icons.opacity,
                    iconColor: Color(0xFF1976D2),
                    title: 'Nível de Água',
                    value: '90%',
                    gradientColors: [Color(0xFFD6EAF8), Color(0xFFEBF5FB)],
                  ),
                  const SizedBox(height: 24),

                  // System Status Card direto no main_screen
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF52B788), Color(0xFF74C69D)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF52B788).withOpacity(0.3),
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
                          child: const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sistema Operacional',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Todos sensores estão a funcionar corretamente',
                                style: TextStyle(
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
    );
  }
}
