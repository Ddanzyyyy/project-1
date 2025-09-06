import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginSplashPage extends StatefulWidget {
  @override
  State<LoginSplashPage> createState() => _LoginSplashPageState();
}

class _LoginSplashPageState extends State<LoginSplashPage> {
  bool isCheckingSession = true;

  @override
  void initState() {
    super.initState();
    _checkLoginSession();
  }

  Future<void> _checkLoginSession() async {
    // Cek apakah sudah login dengan mengecek token di SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null && token.isNotEmpty) {
      // Jika token ada, langsung ke WelcomePage tanpa ke halaman login
      // Ganti '/welcome' dengan route yang sesuai di aplikasi kamu
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacementNamed(context, '/welcome');
      });
    } else {
      // Jika belum login, tampilkan tombol login
      setState(() {
        isCheckingSession = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isCheckingSession
          ? Center(child: CircularProgressIndicator(color: Color(0xFF405189)))
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255, 255, 255, 255),
                    Color.fromARGB(255, 255, 255, 255),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Background circles
                  Positioned(
                    top: -50,
                    right: -50,
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
                    top: 150,
                    right: 60,
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
                    top: 555,
                    bottom: -89,
                    left: -54,
                    child: Container(
                      width: 210,
                      height: 203,
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
                  Positioned(
                    top: 555,
                    bottom: 100,
                    right: 90,
                    left: 40,
                    child: Container(
                      width: 80.4,
                      height: 81.8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF27519D),
                            const Color.fromARGB(255, 144, 160, 190),
                            const Color(0x00C4C4C4),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 30),
                        // // --- Lottie Gift Animation ---
                        // SizedBox(
                        //   width: 110,
                        //   height: 110,
                        //   child: Image.asset(
                        //     'assets/lottie/idea.gif', // path ke file GIF
                        //     fit: BoxFit.contain,
                        //   ),
                        // ),
                        const SizedBox(height: 20),
                        Image.asset(
                          'assets/images/LOGO_INDOCEMENT.jpg',
                          width: 190,
                          height: 140,
                          fit: BoxFit.contain,
                        ),
                        Image.asset(
                          'assets/images/SIMBA.png',
                          width: 270,
                          height: 30,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          'Goods and Asset Management\nInformation System',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF405189),
                            fontSize: 20,
                            fontFamily: 'Mainson Book',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: 176,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF405189),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 5,
                            ),
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                fontFamily: 'Maison Bold',
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}