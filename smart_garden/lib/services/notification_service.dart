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
  bool _permissionGranted = false;

  // Mapa para rastrear quando a última notificação foi enviada para cada sensor
  final Map<String, DateTime> _lastNotificationTime = {};
  // Intervalo mínimo entre notificações (em minutos)
  static const int _notificationCooldownMinutes = 5;

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
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

    // Solicitar permissão para notificações no Android 13+
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // Para Android 13+ (API 33+)
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      _permissionGranted = granted ?? false;

      if (_permissionGranted) {
        print(' Permissão de notificações concedida');
      } else {
        print(' Permissão de notificações negada');
      }
    }
  }

  Future<void> checkSensorValues(SensorData data) async {
    if (!_permissionGranted) {
      print(' Notificações desativadas - permissão não concedida');
      return;
    }

    final warnings = <String>[];
    final now = DateTime.now();

    // Função auxiliar para verificar se deve notificar
    bool shouldNotify(String sensorKey) {
      final lastTime = _lastNotificationTime[sensorKey];
      if (lastTime == null) return true;

      final difference = now.difference(lastTime);
      return difference.inMinutes >= _notificationCooldownMinutes;
    }

    // Verificar temperatura
    if (data.temperaturaAr < SensorLimits.temperaturaArMin) {
      if (shouldNotify('temperatura_baixa')) {
        warnings.add(
          ' Temperatura baixa: ${data.temperaturaAr.toStringAsFixed(1)}°C',
        );
        _lastNotificationTime['temperatura_baixa'] = now;
      }
    } else if (data.temperaturaAr > SensorLimits.temperaturaArMax) {
      if (shouldNotify('temperatura_alta')) {
        warnings.add(
          ' Temperatura alta: ${data.temperaturaAr.toStringAsFixed(1)}°C',
        );
        _lastNotificationTime['temperatura_alta'] = now;
      }
    } else {
      // Limpar notificações quando valores voltam ao normal
      _lastNotificationTime.remove('temperatura_baixa');
      _lastNotificationTime.remove('temperatura_alta');
    }

    // Verificar humidade do ar
    if (data.humidadeAr < SensorLimits.humidadeArMin) {
      if (shouldNotify('humidade_ar_baixa')) {
        warnings.add(
          ' Humidade do ar baixa: ${data.humidadeAr.toStringAsFixed(1)}%',
        );
        _lastNotificationTime['humidade_ar_baixa'] = now;
      }
    } else if (data.humidadeAr > SensorLimits.humidadeArMax) {
      if (shouldNotify('humidade_ar_alta')) {
        warnings.add(
          ' Humidade do ar alta: ${data.humidadeAr.toStringAsFixed(1)}%',
        );
        _lastNotificationTime['humidade_ar_alta'] = now;
      }
    } else {
      _lastNotificationTime.remove('humidade_ar_baixa');
      _lastNotificationTime.remove('humidade_ar_alta');
    }

    // Verificar humidade do solo
    if (data.umidadeSolo < SensorLimits.umidadeSoloMin) {
      if (shouldNotify('solo_seco')) {
        warnings.add(' Solo seco: ${data.umidadeSolo.toStringAsFixed(1)}%');
        _lastNotificationTime['solo_seco'] = now;
      }
    } else if (data.umidadeSolo > SensorLimits.umidadeSoloMax) {
      if (shouldNotify('solo_humido')) {
        warnings.add(
          ' Solo muito húmido: ${data.umidadeSolo.toStringAsFixed(1)}%',
        );
        _lastNotificationTime['solo_humido'] = now;
      }
    } else {
      _lastNotificationTime.remove('solo_seco');
      _lastNotificationTime.remove('solo_humido');
    }

    // Verificar nível de água
    if (data.nivelAgua < SensorLimits.nivelAguaMin) {
      if (shouldNotify('nivel_agua_baixo')) {
        warnings.add(
          ' Nível de água baixo: ${data.nivelAgua.toStringAsFixed(1)}',
        );
        _lastNotificationTime['nivel_agua_baixo'] = now;
      }
    } else {
      _lastNotificationTime.remove('nivel_agua_baixo');
    }

    // Verificar luz
    if (data.nivelLuz < SensorLimits.nivelLuzMin) {
      if (shouldNotify('luz_baixa')) {
        warnings.add(' Pouca luz: ${data.nivelLuz.toStringAsFixed(1)}');
        _lastNotificationTime['luz_baixa'] = now;
      }
    } else if (data.nivelLuz > SensorLimits.nivelLuzMax) {
      if (shouldNotify('luz_alta')) {
        warnings.add(' Luz excessiva: ${data.nivelLuz.toStringAsFixed(1)}');
        _lastNotificationTime['luz_alta'] = now;
      }
    } else {
      _lastNotificationTime.remove('luz_baixa');
      _lastNotificationTime.remove('luz_alta');
    }

    if (warnings.isNotEmpty) {
      print(' Alertas detetados: ${warnings.join(", ")}');
      await _showWarningNotification(warnings);
    }
  }

  Future<void> _showWarningNotification(List<String> warnings) async {
    const androidDetails = AndroidNotificationDetails(
      'sensor_warnings',
      'Alertas de Sensores',
      channelDescription:
          'Notificações quando sensores atingem valores críticos',
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
      ' Alerta Smart Garden',
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

    await _notifications.show(1, title, body, details);
  }
}
