import 'package:Simba/screens/scan_assets/scan_asset_page/recent_assets_scan/screen/scan_asset_page.dart';
import 'package:Simba/screens/setting_screen/notification_service.dart';
import 'package:Simba/screens/setting_screen/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/login/login_splash_page.dart';
import 'screens/login/login_page.dart';
import 'screens/login/forgot_password_page.dart';
import 'screens/welcome_page/welcome_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  
  
  // Initialize notification service
  await NotificationService.initialize();
  await initializeDateFormatting('id_ID', null);
  
  runApp(const SimbaApp());
}

class SimbaApp extends StatelessWidget {
  const SimbaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SIMBA App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Maison Book', 
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Maison Bold'),
          displayMedium: TextStyle(fontFamily: 'Maison Bold'),
          displaySmall: TextStyle(fontFamily: 'Maison Bold'),
          headlineLarge: TextStyle(fontFamily: 'Maison Bold'),
          headlineMedium: TextStyle(fontFamily: 'Maison Bold'),
          headlineSmall: TextStyle(fontFamily: 'Maison Bold'),
          titleLarge: TextStyle(fontFamily: 'Maison Bold'),
          titleMedium: TextStyle(fontFamily: 'Maison Bold'),
          titleSmall: TextStyle(fontFamily: 'Maison Bold'),
          bodyLarge: TextStyle(fontFamily: 'Maison Book'),
          bodyMedium: TextStyle(fontFamily: 'Maison Book'),
          bodySmall: TextStyle(fontFamily: 'Maison Book'),
          labelLarge: TextStyle(fontFamily: 'Maison Bold'),
          labelMedium: TextStyle(fontFamily: 'Maison Book'),
          labelSmall: TextStyle(fontFamily: 'Maison Book'),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: const TextStyle(
              fontFamily: 'Maison Bold',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            textStyle: const TextStyle(
              fontFamily: 'Maison Book',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
            fontFamily: 'Maison Bold',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(fontFamily: 'Maison Book'),
          hintStyle: TextStyle(fontFamily: 'Maison Book'),
          helperStyle: TextStyle(fontFamily: 'Maison Book'),
          errorStyle: TextStyle(fontFamily: 'Maison Book'),
        ),
        snackBarTheme: const SnackBarThemeData(
          contentTextStyle: TextStyle(fontFamily: 'Maison Bold'),
        ),
        dialogTheme: const DialogTheme(
          titleTextStyle: TextStyle(
            fontFamily: 'Maison Bold',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.black87,
          ),
          contentTextStyle: TextStyle(
            fontFamily: 'Maison Book',
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ),
      home: LoginSplashPage(),
      routes: {
        '/login': (context) => LoginPage(),
        '/forgot-password': (context) => ForgotPasswordPage(),
        '/welcome': (context) => WelcomePage(),
        '/scan-assets': (context) => ScanAssetPage(),
        '/settings': (context) => SettingsPage(),
      },
    );
  }
}