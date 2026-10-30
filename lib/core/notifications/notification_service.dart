import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../features/scanner/translation_service.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const int reminderNotificationId = 1001;
  static const int testNotificationId = 1002;
  static const String channelId = 'polish_ai_daily_reminder';
  static const String channelName = 'Polish AI Daily Reminders';
  static const String channelDescription = 'Reminders to practice Polish and review due words';

  static const String prefNotificationsEnabled = 'notifications_daily_enabled';
  static const String prefNotificationsHour = 'notifications_daily_hour';
  static const String prefNotificationsMinute = 'notifications_daily_minute';

  FlutterLocalNotificationsPlugin get plugin => _plugin;
  bool get isInitialized => _initialized;

  Future<void> init() async {
    if (_initialized) return;

    try {
      tz.initializeTimeZones();
      _setupLocalTimezone();
    } catch (e) {
      debugPrint('Timezone initialization error: $e');
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    try {
      await _plugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('Notification clicked: ${response.payload}');
        },
      );
      _initialized = true;
    } catch (e) {
      debugPrint('Failed to initialize local notifications: $e');
    }
  }

  void _setupLocalTimezone() {
    try {
      final offsetHours = DateTime.now().timeZoneOffset.inHours;
      if (offsetHours == 1) {
        tz.setLocalLocation(tz.getLocation('Europe/Warsaw'));
      } else if (offsetHours == 2 || offsetHours == 3) {
        tz.setLocalLocation(tz.getLocation('Europe/Kyiv'));
      } else {
        tz.setLocalLocation(tz.getLocation('Europe/Warsaw'));
      }
    } catch (_) {
      try {
        tz.setLocalLocation(tz.local);
      } catch (_) {}
    }
  }

  Future<bool> requestPermission() async {
    if (kIsWeb) return false;
    try {
      if (!kIsWeb && Platform.isAndroid) {
        final androidImpl = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        final granted = await androidImpl?.requestNotificationsPermission();
        return granted ?? false;
      } else if (!kIsWeb && Platform.isIOS) {
        final iosImpl = _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
        final granted = await iosImpl?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
    }
    return true;
  }

  NotificationDetails _buildNotificationDetails() {
    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    return const NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );
  }

  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required UiLang language,
    int dueWordsCount = 0,
    int streakDays = 0,
  }) async {
    if (!_initialized) await init();

    try {
      await _plugin.cancel(id: reminderNotificationId);

      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final texts = getNotificationContent(
        language: language,
        dueWordsCount: dueWordsCount,
        streakDays: streakDays,
      );

      await _plugin.zonedSchedule(
        id: reminderNotificationId,
        title: texts.title,
        body: texts.body,
        scheduledDate: scheduledDate,
        notificationDetails: _buildNotificationDetails(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint('Scheduled daily reminder at $hour:${minute.toString().padLeft(2, '0')} ($scheduledDate)');
    } catch (e) {
      debugPrint('Failed to schedule reminder: $e');
    }
  }

  Future<void> sendTestNotification({
    required UiLang language,
    int dueWordsCount = 0,
    int streakDays = 0,
  }) async {
    if (!_initialized) await init();

    final texts = getNotificationContent(
      language: language,
      dueWordsCount: dueWordsCount,
      streakDays: streakDays,
      isTest: true,
    );

    try {
      await _plugin.show(
        id: testNotificationId,
        title: texts.title,
        body: texts.body,
        notificationDetails: _buildNotificationDetails(),
      );
    } catch (e) {
      debugPrint('Failed to send test notification: $e');
    }
  }

  Future<void> cancelDailyReminder() async {
    if (!_initialized) await init();
    try {
      await _plugin.cancel(id: reminderNotificationId);
    } catch (e) {
      debugPrint('Failed to cancel reminder: $e');
    }
  }

  static ({String title, String body}) getNotificationContent({
    required UiLang language,
    int dueWordsCount = 0,
    int streakDays = 0,
    bool isTest = false,
  }) {
    final isPl = language == UiLang.pl;
    final isUk = language == UiLang.uk;

    if (isTest) {
      if (isPl) {
        return (
          title: '🔔 Polish AI Tutor działa!',
          body: 'Powiadomienia są aktywne. Czas na codzienną dawkę polskiego!',
        );
      } else if (isUk) {
        return (
          title: '🔔 Polish AI Tutor працює!',
          body: 'Сповіщення активні. Час для щоденної порції польської мови!',
        );
      } else {
        return (
          title: '🔔 Polish AI Tutor работает!',
          body: 'Уведомления активны. Время для ежедневной порции польского языка!',
        );
      }
    }

    if (dueWordsCount > 0) {
      if (isPl) {
        return (
          title: '🧠 Czas na powtórkę słówek!',
          body: 'Czeka na Ciebie $dueWordsCount słówek w systemie SM-2. Poćwicz 3 minuty!',
        );
      } else if (isUk) {
        return (
          title: '🧠 Час повторити слова!',
          body: 'Вас чекають $dueWordsCount слів за системою SM-2. Зайдіть на 3 хвилини!',
        );
      } else {
        return (
          title: '🧠 Время повторить слова!',
          body: 'Вас ждут $dueWordsCount слов по системе SM-2. Зайдите на 3 минуты!',
        );
      }
    }

    if (streakDays > 0) {
      if (isPl) {
        return (
          title: '🔥 Utrzymaj serię nauki: $streakDays dni!',
          body: 'Nie przerywaj passy! Rozwiąż krótki quiz lub powtórz kilka zdań.',
        );
      } else if (isUk) {
        return (
          title: '🔥 Збережи свій ударний режим: $streakDays днів!',
          body: 'Не переривай серію! Пройди короткий квіз або діалог сьогодні.',
        );
      } else {
        return (
          title: '🔥 Сохрани свой ударный режим: $streakDays дней!',
          body: 'Не прерывай серию! Пройди короткий квиз или диалог сегодня.',
        );
      }
    }

    if (isPl) {
      return (
        title: '🇵🇱 Codzienna dawka polskiego!',
        body: 'Poświęć 5 minut na naukę: nowe słówka i żywy dialog czekają.',
      );
    } else if (isUk) {
      return (
        title: '🇵🇱 Щоденна порція польської!',
        body: 'Приділіть 5 хвилин навчанню: нові слова та живий діалог чекають.',
      );
    } else {
      return (
        title: '🇵🇱 Ежедневная порция польского!',
        body: 'Уделите 5 минут обучению: новые слова и живой диалог ждут вас.',
      );
    }
  }
}
