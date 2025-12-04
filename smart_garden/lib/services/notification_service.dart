import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/sensor_data.dart';
import '../models/sensor_limits.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
  }

  Future<void> checkSensorValues(SensorData data) async {
    final warnings = <String>[];

    // Verificar temperatura
    if (data.temperaturaAr < SensorLimits.temperaturaArMin) {
      warnings.add('🌡️ Temperatura baixa: ${data.temperaturaAr.toStringAsFixed(1)}°C');
    } else if (data.temperaturaAr > SensorLimits.temperaturaArMax) {
      warnings.add('🌡️ Temperatura alta: ${data.temperaturaAr.toStringAsFixed(1)}°C');
    }

    // Verificar humidade do ar
    if (data.humidadeAr < SensorLimits.humidadeArMin) {
      warnings.add('💧 Humidade do ar baixa: ${data.humidadeAr.toStringAsFixed(1)}%');
    } else if (data.humidadeAr > SensorLimits.humidadeArMax) {
      warnings.add('💧 Humidade do ar alta: ${data.humidadeAr.toStringAsFixed(1)}%');
    }

    // Verificar humidade do solo
    if (data.umidadeSolo < SensorLimits.umidadeSoloMin) {
      warnings.add('🌱 Solo seco: ${data.umidadeSolo.toStringAsFixed(1)}%');
    } else if (data.umidadeSolo > SensorLimits.umidadeSoloMax) {
      warnings.add('🌱 Solo muito húmido: ${data.umidadeSolo.toStringAsFixed(1)}%');
    }

    // Verificar nível de água
    if (data.nivelAgua < SensorLimits.nivelAguaMin) {
      warnings.add('💦 Nível de água baixo: ${data.nivelAgua.toStringAsFixed(1)}');
    }

    // Verificar luz
    if (data.nivelLuz < SensorLimits.nivelLuzMin) {
      warnings.add('☀️ Pouca luz: ${data.nivelLuz.toStringAsFixed(1)}');
    } else if (data.nivelLuz > SensorLimits.nivelLuzMax) {
      warnings.add('☀️ Luz excessiva: ${data.nivelLuz.toStringAsFixed(1)}');
    }

    if (warnings.isNotEmpty) {
      await _showWarningNotification(warnings);
    }
  }

  Future<void> _showWarningNotification(List<String> warnings) async {
    const androidDetails = AndroidNotificationDetails(
      'sensor_warnings',
      'Alertas de Sensores',
      channelDescription: 'Notificações quando sensores atingem valores críticos',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFFF6B6B),
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      '⚠️ Alerta Smart Garden',
      warnings.length == 1 
        ? warnings.first 
        : '${warnings.length} sensores em estado crítico',
      details,
      payload: warnings.join('\n'),
    );
  }

  Future<void> showInfoNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'info_channel',
      'Informações',
      channelDescription: 'Notificações informativas',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      1,
      title,
      body,
      details,
    );
  }
}