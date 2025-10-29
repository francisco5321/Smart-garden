import 'package:flutter/material.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const SmartGardenApp());
}

class SmartGardenApp extends StatelessWidget {
  const SmartGardenApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Garden',
      debugShowCheckedModeBanner: false, // Remove a faixa "DEBUG"
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MainScreen(),
    );
  }
}
