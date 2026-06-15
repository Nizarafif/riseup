import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const int dailyReminderId = 42;
  static const String channelId = 'reflection_reminder_channel';
  static const String channelName = 'Pengingat Refleksi Harian';
  static const String channelDesc = 'Saluran untuk pengingat refleksi kesehatan mental harian';

  Future<void> initialize() async {
    // 1. Inisialisasi Database Timezone & Set Local Location
    tz.initializeTimeZones();
    try {
      final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      final String timeZoneName = timeZoneInfo.identifier;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint('Local timezone set to: $timeZoneName');
    } catch (e) {
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
        debugPrint('Fallback local timezone set to: Asia/Jakarta');
      } catch (e2) {
        debugPrint('Gagal menyetel fallback timezone: $e2');
      }
    }
    
    // 2. Konfigurasi Pengaturan Android (menggunakan launcher_icon bawaan)
    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');

    // 3. Konfigurasi Pengaturan iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // 4. Inisialisasi Plugin
    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('Notifikasi diklik: ${details.payload}');
      },
    );

    // 5. Buat Notification Channel untuk Android (Penting untuk Android 8.0+)
    const androidChannel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDesc,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
    
    debugPrint('NotificationService berhasil diinisialisasi.');
  }

  // Meminta Izin Notifikasi secara rill (untuk Android 13+ & iOS)
  Future<bool> requestPermission() async {
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    bool? grantedAndroid = false;
    if (androidImplementation != null) {
      grantedAndroid = await androidImplementation.requestNotificationsPermission();
    }

    final iosImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    
    bool? grantedIos = false;
    if (iosImplementation != null) {
      grantedIos = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    final isGranted = (grantedAndroid ?? false) || (grantedIos ?? false);
    debugPrint('Status izin notifikasi: $isGranted');
    return isGranted;
  }

  // Menjadwalkan pengingat harian pada jam tertentu
  Future<void> scheduleDailyReminder(TimeOfDay time, {bool skipToday = false}) async {
    // Batalkan pengingat lama terlebih dahulu untuk mencegah penumpukan
    await cancelDailyReminder();

    // Simpan jam pengingat ke SharedPreferences agar bisa diakses saat log mood/screening
    await _saveReminderTime(time);

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Jika waktu yang dijadwalkan sudah lewat hari ini atau dipaksa untuk dilewati (karena sudah log mood/screening)
    if (skipToday || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      dailyReminderId,
      'Waktunya Refleksi Harian 🌟',
      'Luangkan waktu sejenak untuk mencatat suasana hatimu hari ini di RiseUp.',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Perulangan harian
    );

    debugPrint('Daily reminder dijadwalkan setiap jam: ${time.hour}:${time.minute} pada $scheduledDate. SkipToday: $skipToday');
  }

  // Simpan jam pengingat ke SharedPreferences
  Future<void> _saveReminderTime(TimeOfDay time) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('reminder_hour', time.hour);
      await prefs.setInt('reminder_minute', time.minute);
    } catch (e) {
      debugPrint('Gagal menyimpan waktu pengingat ke SharedPreferences: $e');
    }
  }

  // Ambil jam pengingat dari SharedPreferences (default 20:00 jika kosong)
  Future<TimeOfDay> getReminderTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hour = prefs.getInt('reminder_hour');
      final minute = prefs.getInt('reminder_minute');
      if (hour != null && minute != null) {
        return TimeOfDay(hour: hour, minute: minute);
      }
      return const TimeOfDay(hour: 20, minute: 0);
    } catch (e) {
      return const TimeOfDay(hour: 20, minute: 0);
    }
  }

  // Dipanggil saat mood berhasil dicatat hari ini
  Future<void> onMoodLogged() async {
    final time = await getReminderTime();
    await scheduleDailyReminder(time, skipToday: true);
    debugPrint('Mood dicatat hari ini. Pengingat refleksi hari ini dilewati (rescheduled ke besok).');
  }

  // Dipanggil saat skrining berhasil dilakukan hari ini
  Future<void> onScreeningCompleted() async {
    final time = await getReminderTime();
    await scheduleDailyReminder(time, skipToday: true);
    debugPrint('Skrining selesai hari ini. Pengingat refleksi hari ini dilewati (rescheduled ke besok).');
  }

  // Membatalkan pengingat harian
  Future<void> cancelDailyReminder() async {
    await _notificationsPlugin.cancel(dailyReminderId);
    debugPrint('Daily reminder dibatalkan.');
  }

  // Membatalkan semua notifikasi
  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
    debugPrint('Semua notifikasi dibatalkan.');
  }
}
