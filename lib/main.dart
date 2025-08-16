import 'package:flutter/material.dart';
import 'screens/login_splash_page.dart';
import 'screens/login_page.dart';
import 'screens/forgot_password_page.dart';
import 'screens/welcome_page.dart';

void main() {
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
        fontFamily: 'Roboto',
      ),
      home: LoginSplashPage(),
      routes: {
        '/login': (context) => LoginPage(),
        '/forgot-password': (context) => ForgotPasswordPage(),
        '/welcome': (context) => WelcomePage(),
      },
    );
  }
}






