import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Simba/screens/welcome_page/welcome_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String usernameWarning = '';
  String passwordWarning = '';
  String apiWarning = '';
  bool isLoading = false;

  static const Color blueDark = Color(0xFF405189);

  String getBaseUrl() {
    if (Platform.isAndroid) {
      return 'http://192.168.1.4:8000/api/login';
    } else {
      return 'http://127.0.0.1:8000/api/login';
    }
  }

  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn();
  }

  Future<void> _checkIfLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null && token.isNotEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => WelcomePage()),
      );
    }
  }

  Future<void> handleLogin(BuildContext context) async {
    setState(() {
      usernameWarning =
          usernameController.text.isEmpty ? 'Username Harus Diisi' : '';
      passwordWarning =
          passwordController.text.isEmpty ? 'Password Harus Diisi' : '';
      apiWarning = '';
    });

    if (usernameWarning.isEmpty && passwordWarning.isEmpty) {
      setState(() {
        isLoading = true;
      });

      try {
        final url = getBaseUrl();
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'User-Agent': 'Flutter App',
          },
          body: jsonEncode({
            'username': usernameController.text,
            'password': passwordController.text,
          }),
        ).timeout(const Duration(seconds: 3));

        setState(() {
          isLoading = false;
        });

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['success'] == true) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('name', data['user']['name']);
            prefs.setString('username', data['user']['username']);
            prefs.setString('token', data['token']);
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => WelcomePage()),
            );
          } else {
            setState(() {
              apiWarning = data['message'] ?? 'Login gagal';
            });
          }
        } else {
          final data = jsonDecode(response.body);
          setState(() {
            apiWarning = data['message'] ?? 'Login gagal';
          });
        }
      } catch (e) {
        setState(() {
          isLoading = false;
          apiWarning = 'Gagal terhubung ke server: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenHeight = media.size.height;
    final screenWidth = media.size.width;
    final isSmallDevice = screenWidth < 400;

    final horizontalPad = screenWidth * 0.08;
    final inputWidth = isSmallDevice ? double.infinity : 300.0;
    final buttonWidth = isSmallDevice ? double.infinity : 300.0;
    final inputFontSize = isSmallDevice ? 13.0 : 14.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Curved accent background top left
          Positioned(
            top: -screenHeight * 0.23,
            left: -screenWidth * 0.25,
            child: Container(
              width: screenWidth * 0.7,
              height: screenHeight * 0.4,
              decoration: BoxDecoration(
                color: blueDark.withOpacity(0.07),
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(screenWidth * 0.6),
                  bottomLeft: Radius.circular(screenWidth * 0.2),
                ),
              ),
            ),
          ),
          // Curved accent background bottom right
          Positioned(
            bottom: -screenHeight * 0.19,
            right: -screenWidth * 0.18,
            child: Container(
              width: screenWidth * 0.6,
              height: screenHeight * 0.32,
              decoration: BoxDecoration(
                color: blueDark.withOpacity(0.09),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(screenWidth * 0.5),
                  topRight: Radius.circular(screenWidth * 0.2),
                ),
              ),
            ),
          ),
          // Dynamic company logo in top right
          Positioned(
            top: screenHeight * 0.03,
            right: screenWidth * 0.04,
            child: Container(
              padding: EdgeInsets.all(screenWidth * 0.015),
              // child: Image.asset(
              //   'assets/images/indocement_logo.png',
              //   width: screenWidth * 0.13,
              //   height: screenWidth * 0.13,
              //   fit: BoxFit.contain,
              // ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: horizontalPad),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Illustration
                    SizedBox(
                      width: 200,
                      height: 190,
                      child: Padding(
                        padding: EdgeInsets.only(top: 37), 
                        child: Image.asset(
                          'assets/images/icons/gif/iventory.gif',
                          fit: BoxFit.contain,
                        ),
                      ),  
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    // Custom "IvenTra" text
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: screenWidth * 0.105,
                          fontFamily: 'Maison Bold',
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                        // children: [
                        //   TextSpan(
                        //     text: 'Iven',
                        //     style: TextStyle(
                        //       color: blueDark,
                        //     ),
                        //   ),
                        //   TextSpan(
                        //     text: 'T',
                        //     style: TextStyle(
                        //       color: Colors.red,
                        //     ),
                        //   ),
                        //   TextSpan(
                        //     text: 'ra',
                        //     style: TextStyle(
                        //       color: blueDark,
                        //     ),
                        //   ),
                        // ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.025),
                    // Subtitle
                    Text(
                      'Goods and Asset Logistic Management Information System',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: blueDark,
                        fontSize: screenWidth * 0.048,
                        fontFamily: 'Maison Book',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.038),
                    // Username
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Username',
                        style: TextStyle(
                          fontFamily: 'Maison Bold',
                          color: blueDark,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: inputWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 47,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: usernameWarning.isNotEmpty
                                    ? Colors.red
                                    : blueDark,
                                width: 1.5,
                              ),
                            ),
                            child: TextField(
                              controller: usernameController,
                              style: TextStyle(
                                fontFamily: 'Maison Book',
                                fontSize: inputFontSize,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter Username',
                                hintStyle: const TextStyle(
                                  fontFamily: 'Maison Book',
                                  color: Colors.grey,
                                ),
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.only(
                                      left: 15, right: 10),
                                  child: Icon(Icons.person_outline,
                                      color: Colors.grey, size: 18),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.only(
                                    top: 11, bottom: 11),
                              ),
                            ),
                          ),
                          if (usernameWarning.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 4, left: 4, right: 4),
                              child: Text(
                                usernameWarning,
                                style: const TextStyle(
                                  fontFamily: 'Maison Book',
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Password
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Password',
                        style: TextStyle(
                          fontFamily: 'Maison Bold',
                          color: blueDark,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: inputWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 47,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: passwordWarning.isNotEmpty
                                    ? Colors.red
                                    : blueDark,
                                width: 1.5,
                              ),
                            ),
                            child: TextField(
                              controller: passwordController,
                              obscureText: true,
                              style: TextStyle(
                                fontFamily: 'Maison Book',
                                fontSize: inputFontSize,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter Password',
                                hintStyle: const TextStyle(
                                  fontFamily: 'Maison Book',
                                  color: Colors.grey,
                                ),
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.only(
                                      left: 15, right: 10),
                                  child: Icon(Icons.lock_outline,
                                      color: Colors.grey, size: 18),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.only(
                                    top: 11, bottom: 11),
                              ),
                            ),
                          ),
                          if (passwordWarning.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 4, left: 4, right: 4),
                              child: Text(
                                passwordWarning,
                                style: const TextStyle(
                                  fontFamily: 'Maison Bold',
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (apiWarning.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 4, left: 4, right: 4),
                        child: Text(
                          apiWarning,
                          style: const TextStyle(
                            fontFamily: 'Maison Bold',
                            color: Colors.red,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: buttonWidth,
                      height: 48,
                      child: ElevatedButton(
                        onPressed:
                            isLoading ? null : () => handleLogin(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blueDark,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 26,
                                height: 26,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(
                                  fontFamily: 'Maison Bold',
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.025),
                    Text(
                      'The data you submit will be processed in accordance with our Privacy Policy. By continuing you agree to Terms.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Maison Book',
                        fontSize: screenWidth * 0.034,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}