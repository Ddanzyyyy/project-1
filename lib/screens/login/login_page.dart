import 'package:flutter/material.dart';

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

  static const Color blueDark = Color(0xFF27519D);
  static const Color blueText = Color(0xFF1E4A8C);

  void handleLogin(BuildContext context) {
    setState(() {
      usernameWarning =
          usernameController.text.isEmpty ? 'Username Harus Diisi' : '';
      passwordWarning =
          passwordController.text.isEmpty ? 'Password Harus Diisi' : '';
    });

    if (usernameWarning.isEmpty && passwordWarning.isEmpty) {
      Navigator.pushNamed(context, '/welcome');
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
                    const Color(0xFF27519D), // biru full
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
                    const Color(0xFF27519D), // biru full
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
                    const Color(0xFF27519D), // biru full
                    const Color.fromARGB(255, 144, 160, 190),
                    const Color(0x00C4C4C4),
                  ],
                ),
              ),
            ),
          ),

          // // BOTTOM CENTER - Small Circle
          // Positioned(
          //   bottom: screenHeight * 0.2,
          //   left: screenWidth * 0.15,
          //   child: Container(
          //     width: 48,
          //     height: 48,
          //     decoration: BoxDecoration(
          //       gradient: LinearGradient(
          //         colors: [
          //           const Color(0xFF27519D), // biru full
          //           const Color.fromARGB(255, 144, 160, 190),
          //           const Color(0x00C4C4C4),
          //         ],
          //       ),
          //       shape: BoxShape.circle,
          //     ),
          //   ),
          // ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo image (from assets, circular)
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
                          color: Color(0xFF27519D),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Username field

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Username
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Username',
                              style: const TextStyle(
                                color: Color(0xFF27519D),
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
                                    decoration: InputDecoration(
                                      hintText: 'Enter Username',
                                      hintStyle:
                                          const TextStyle(color: Colors.grey),
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
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                                if (usernameWarning.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 4, left: 4, right: 4),
                                    child: Text(
                                      usernameWarning,
                                      style: const TextStyle(
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
                              style: const TextStyle(
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
                                    decoration: InputDecoration(
                                      hintText: 'Enter Password',
                                      hintStyle:
                                          const TextStyle(color: Colors.grey),
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
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                                if (passwordWarning.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 4, left: 4, right: 4),
                                    child: Text(
                                      passwordWarning,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 25),
                          // Login button
                          SizedBox(
                            width: 300,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () => handleLogin(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF405189),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 2,
                              ),
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, '/forgot-password');
                                },
                                child: const Text(
                                  'Forgot your password ?',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF27519D),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ]),
              ),
            ),
          )
        ],
      ),
    );
  }
}
