import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    print('🔧 Carregando .env...');
    await dotenv.load(fileName: ".env");
    print('✅ .env carregado com sucesso!');
    print('📍 MQTT Broker: ${dotenv.env['MQTT_BROKER']}');
    print('📍 MQTT Port: ${dotenv.env['MQTT_PORT']}');
    print('📍 Client ID: ${dotenv.env['MQTT_CLIENT_ID']}');
  } catch (e) {
    print('🔴 Erro ao carregar .env: $e');
    print('⚠️ Usando valores padrão');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Garden',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
