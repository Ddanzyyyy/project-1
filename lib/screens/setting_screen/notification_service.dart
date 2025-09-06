import 'dart:ui';

import 'package:Simba/screens/registered_page/asset_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  // Handle notification tap
  static void _onNotificationTapped(NotificationResponse notificationResponse) {
    final payload = notificationResponse.payload;
    if (payload != null) {
      print('Notification tapped with payload: $payload');
    }
  }

  // Request notification permissions
  static Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      return status == PermissionStatus.granted;
    } else if (Platform.isIOS) {
      final bool? result = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    }
    return false;
  }

  // Check and send asset notifications - DIPERBAIKI
  static Future<void> checkAndSendAssetNotifications() async {
    try {
      print('🔔 Fungsi checkAndSendAssetNotifications dipanggil');
      
      final prefs = await SharedPreferences.getInstance();
      final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true; //true
      final pushNotifications = prefs.getBool('push_notifications') ?? true;
      
      print('📱 Notifications enabled: $notificationsEnabled, Push enabled: $pushNotifications');
      
      if (!notificationsEnabled || !pushNotifications) {
        print('❌ Notifikasi tidak aktif, keluar dari fungsi');
        return;
      }

      final assets = await AssetService.getAssets();
      print('📦 Total assets dari API: ${assets.length}');
      
      // Debug: Print semua asset dan statusnya
      for (final asset in assets) {
        print('Asset: ${asset.name} - Status: ${asset.status}');
      }
      
      // Hitung asset berdasarkan status (sesuai model Asset kamu tanpa lastScanned)
      final damagedCount = assets.where((asset) => 
        asset.status.toLowerCase() == 'damaged').length;
      
      final lostCount = assets.where((asset) => 
        asset.status.toLowerCase() == 'lost').length;
      
      final maintenanceCount = assets.where((asset) => 
        asset.status.toLowerCase() == 'maintenance').length;

      // Asset yang available (bisa dianggap "unscanned" jika belum ada field lastScanned)
      final availableCount = assets.where((asset) => 
        asset.status.toLowerCase() == 'available').length;

      print('📊 Status Count:');
      print('   - Damaged: $damagedCount');
      print('   - Lost: $lostCount');
      print('   - Maintenance: $maintenanceCount');
      print('   - Available: $availableCount');

      // Kirim notifikasi berdasarkan kondisi yang ada
      if (damagedCount > 0) {
        print('🚨 Mengirim notifikasi asset rusak');
        await _sendDamagedNotification(damagedCount);
      }

      if (lostCount > 0) {
        print('🚨 Mengirim notifikasi asset hilang');
        await _sendLostNotification(lostCount);
      }

      if (maintenanceCount > 0) {
        print('🔧 Mengirim notifikasi asset maintenance');
        await _sendMaintenanceNotification(maintenanceCount);
      }

      // Optional: Kirim notifikasi jika ada asset available yang mungkin perlu dicek
      if (availableCount > 0 && damagedCount == 0 && lostCount == 0) {
        print('📋 Mengirim notifikasi asset tersedia untuk dicek');
        await _sendAvailableAssetsNotification(availableCount);
      }

      // Optional: Notifikasi jika semua asset dalam kondisi baik
      if (damagedCount == 0 && lostCount == 0 && maintenanceCount == 0 && availableCount > 0) {
        print('✅ Mengirim notifikasi semua asset baik');
        await _sendAllAssetsGoodNotification(availableCount);
      }

      // Log notification check
      await prefs.setString('last_notification_check', DateTime.now().toIso8601String());
      print('✅ Pemeriksaan notifikasi selesai');

    } catch (e) {
      print('❌ Error checking asset notifications: $e');
    }
  }

  // Send available assets notification (pengganti unscanned)
  static Future<void> _sendAvailableAssetsNotification(int count) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'available_assets',
      'Available Assets',
      channelDescription: 'Notifications for available assets to check',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF405189),
      styleInformation: BigTextStyleInformation(''),
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      1,
      'Asset Tersedia untuk Dicek',
      'Anda memiliki $count asset yang tersedia dan siap untuk pengecekan',
      platformChannelSpecifics,
      payload: 'available_assets',
    );
  }

  // Send damaged asset notification
  static Future<void> _sendDamagedNotification(int count) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'damaged_assets',
      'Damaged Assets',
      channelDescription: 'Notifications for damaged assets',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFFF6B35),
      styleInformation: BigTextStyleInformation(''),
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      2,
      'Asset Rusak',
      'Anda memiliki $count asset yang rusak, segera lakukan perbaikan',
      platformChannelSpecifics,
      payload: 'damaged_assets',
    );
  }

  // Send lost asset notification
  static Future<void> _sendLostNotification(int count) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'lost_assets',
      'Lost Assets',
      channelDescription: 'Notifications for lost assets',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFDC3545),
      styleInformation: BigTextStyleInformation(''),
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      3,
      'Asset Hilang',
      'Anda memiliki $count asset yang hilang, segera hubungi admin gudang',
      platformChannelSpecifics,
      payload: 'lost_assets',
    );
  }

  // Send maintenance notification - BARU
  static Future<void> _sendMaintenanceNotification(int count) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'maintenance_assets',
      'Maintenance Assets',
      channelDescription: 'Notifications for assets under maintenance',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFFFC107),
      styleInformation: BigTextStyleInformation(''),
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      4,
      'Asset Dalam Maintenance',
      'Anda memiliki $count asset yang sedang dalam perbaikan',
      platformChannelSpecifics,
      payload: 'maintenance_assets',
    );
  }

  // Send all assets good notification - BARU
  static Future<void> _sendAllAssetsGoodNotification(int count) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'all_assets_good',
      'All Assets Good',
      channelDescription: 'Notifications when all assets are in good condition',
      importance: Importance.low,
      priority: Priority.low,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF28A745),
      styleInformation: BigTextStyleInformation(''),
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      5,
      'Semua Asset Dalam Kondisi Baik',
      'Total $count asset tersedia dan tidak ada masalah',
      platformChannelSpecifics,
      payload: 'all_assets_good',
    );
  }

  // static Future<void> _sendUnscannedNotification(int count) async {
  //   await _sendAvailableAssetsNotification(count);
  // }

  // static Future<void> _sendOutdatedNotification(int count) async {
  //   // Tidak digunakan karena model tidak punya lastScanned
  //   print('Outdated notification skipped - no lastScanned field in model');
  // }

  static Future<void> scheduleDailyAssetCheck() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    
    final now = tz.TZDateTime.now(tz.getLocation('Asia/Jakarta'));
    var scheduledDate = tz.TZDateTime(tz.getLocation('Asia/Jakarta'), now.year, now.month, now.day, 9);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      100,
      'Pemeriksaan Asset Harian',
      'Waktunya memeriksa status asset hari ini',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_asset_check',
          'Daily Asset Check',
          channelDescription: 'Daily automatic asset status check at 9 AM WIB',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFF405189),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_check',
    );

    // Save schedule info
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('scheduled_daily_check', scheduledDate.toIso8601String());
  }

  static Future<void> scheduleWeeklySummary() async {
    final now = tz.TZDateTime.now(tz.getLocation('Asia/Jakarta'));
    
    var scheduledDate = tz.TZDateTime(tz.getLocation('Asia/Jakarta'), now.year, now.month, now.day, 8);
    final daysUntilMonday = (8 - now.weekday) % 7;
    scheduledDate = scheduledDate.add(Duration(days: daysUntilMonday == 0 ? 7 : daysUntilMonday));

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      101,
      'Ringkasan Asset Mingguan',
      'Lihat ringkasan kondisi asset minggu ini',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weekly_summary',
          'Weekly Asset Summary',
          channelDescription: 'Weekly asset status summary every Monday',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFF405189),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: 'weekly_summary',
    );
  }

  // Enable automatic notifications
  static Future<void> enableAutomaticNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('automatic_notifications', true);
    
    // Schedule daily and weekly notifications
    await scheduleDailyAssetCheck();
    await scheduleWeeklySummary();
    
    print('Automatic notifications enabled');
  }

  // Disable automatic notifications
  static Future<void> disableAutomaticNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('automatic_notifications', false);

    // Cancel scheduled notifications
    await _flutterLocalNotificationsPlugin.cancel(100);
    await _flutterLocalNotificationsPlugin.cancel(101);
    
    print('Automatic notifications disabled');
  }

  static Future<bool> isUserAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';
    return username == 'caccarehana' || username == 'admin'; 
  }

  // Send immediate notification when asset status changes to critical
  static Future<void> notifyAssetStatusChange(String assetName, String newStatus) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true; //true
    
    if (!notificationsEnabled) return;

    String title = '';
    String body = '';
    Color color = const Color(0xFF405189);

    switch (newStatus.toLowerCase()) {
      case 'damaged':
        title = 'Asset Rusak Terdeteksi';
        body = 'Asset "$assetName" telah dilaporkan rusak';
        color = const Color(0xFFFF6B35);
        break;
      case 'lost':
        title = 'Asset Hilang Terdeteksi';
        body = 'Asset "$assetName" telah dilaporkan hilang';
        color = const Color(0xFFDC3545);
        break;
      case 'maintenance':
        title = 'Asset Dalam Maintenance';
        body = 'Asset "$assetName" sedang dalam perbaikan';
        color = const Color(0xFFFFC107);
        break;
    }

    if (title.isNotEmpty) {
      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'asset_status_change',
            'Asset Status Changes',
            channelDescription: 'Immediate notifications for asset status changes',
            importance: Importance.max,
            priority: Priority.max,
            icon: '@mipmap/ic_launcher',
            color: color,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: 'status_change_$newStatus',
      );
    }
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // Method untuk test notifikasi manual
  static Future<void> testNotification() async {
    await _sendDamagedNotification(1);
  }
}