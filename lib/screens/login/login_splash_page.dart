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
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null && token.isNotEmpty) {
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacementNamed(context, '/welcome');
      });
    } else {
      setState(() {
        isCheckingSession = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: isCheckingSession
          ? Center(child: CircularProgressIndicator(color: Color(0xFF405189)))
          : Stack(
              children: [
                // Curved accent background top left
                Positioned(
                  top: -screenHeight * 0.23,
                  left: -screenWidth * 0.25,
                  child: Container(
                    width: screenWidth * 0.7,
                    height: screenHeight * 0.4,
                    decoration: BoxDecoration(
                      color: Color(0xFF405189).withOpacity(0.07),
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
                      color: Color(0xFF405189).withOpacity(0.09),
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
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Illustration
                        SizedBox(
                          width: 200,
                          height: 160,
                          child: Image.asset(
                            'assets/images/icons/gif/iventory.gif',
                            fit: BoxFit.contain,
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
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.025),
                        // Subtitle
                        Text(
                          'Goods and Asset Logistic Management Information System',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF405189),
                            fontSize: screenWidth * 0.048,
                            fontFamily: 'Maison Book',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.038),
                        SizedBox(
                          width: double.infinity,
                          height: screenHeight * 0.062,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF405189),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Login',
                              style: TextStyle(
                                fontFamily: 'Maison Bold',
                                color: Colors.white,
                                fontSize: screenWidth * 0.048,
                                fontWeight: FontWeight.w700,
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
              ],
            ),
    );
  }
}