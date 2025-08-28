import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

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

  static const Color blueDark = Color(0xFF27519D);

  String getBaseUrl() {
    if (Platform.isAndroid) {
      return 'http://192.168.8.131:8000/api/login';
    } else {
      return 'http://127.0.0.1:8000/api/login'; // IOS
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
        print('Mengirim request ke: $url');
        print('Body: ${jsonEncode({
          'username': usernameController.text,
          'password': passwordController.text,
        })}');

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

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        setState(() {
          isLoading = false;
        });

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['success'] == true) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('name', data['user']['name']);
            prefs.setString('username', data['user']['username']);
            prefs.setString('token', data['token']); // jika butuh token
            Navigator.pushNamed(context, '/welcome');
          } else {
            // Login gagal, tampilkan pesan error dari API
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
        print('Error detail: $e');
        setState(() {
          isLoading = false;
          apiWarning = 'Gagal terhubung ke server: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF27519D),
                    const Color.fromARGB(255, 144, 160, 190),
                    const Color(0x00C4C4C4),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.15,
            right: screenWidth * 0.12,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF27519D),
                    const Color.fromARGB(255, 144, 160, 190),
                    const Color(0x00C4C4C4),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF27519D),
                    const Color.fromARGB(255, 144, 160, 190),
                    const Color(0x00C4C4C4),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(),
                      child: Image.asset(
                        'assets/images/LOGO_INDOCEMENT.jpg',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Image.asset(
                      'assets/images/SIMBA.png',
                      width: 270,
                      height: 30,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Goods and Asset Management\nInformation System',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Color(0xFF27519D),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Username',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: blueDark,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 300,
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
                                        : const Color(0xFF405189),
                                    width: 1.5,
                                  ),
                                ),
                                child: TextField(
                                  controller: usernameController,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Enter Username',
                                    hintStyle: const TextStyle(
                                      fontFamily: 'Inter',
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
                                      fontFamily: 'Inter',
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
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Password',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              color: Color(0xFF405189),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 300,
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
                                        : const Color(0xFF405189),
                                    width: 1.5,
                                  ),
                                ),
                                child: TextField(
                                  controller: passwordController,
                                  obscureText: true,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Enter Password',
                                    hintStyle: const TextStyle(
                                      fontFamily: 'Inter',
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
                                      fontFamily: 'Inter',
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
                                fontFamily: 'Inter',
                                color: Colors.red,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        const SizedBox(height: 25),
                        SizedBox(
                          width: 300,
                          height: 48,
                          child: ElevatedButton(
                            onPressed:
                                isLoading ? null : () => handleLogin(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF405189),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 2,
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
                                      fontFamily: 'Inter',
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                            ),
                          ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}