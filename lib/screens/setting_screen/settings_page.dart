import 'package:Simba/screens/setting_screen/setting_about_card.dart';
import 'package:Simba/screens/setting_screen/setting_acount_card.dart';
import 'package:Simba/screens/setting_screen/setting_header.dart';
import 'package:Simba/screens/setting_screen/setting_section.dart';
import 'package:Simba/screens/setting_screen/setting_notification.dart';
import 'package:Simba/screens/activity_screen/screen/activity_page.dart';
import 'package:Simba/screens/home_screen/profile/edit_profile_page.dart';
import 'package:Simba/screens/scan_assets/scan_asset_page/recent_assets_scan/screen/scan_asset_page.dart';
import 'package:Simba/screens/welcome_page/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ==== REUSABLE NAVBAR ====
class AppBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const AppBottomNavBar({required this.selectedIndex, required this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(context, Icons.home_rounded, "Home", 0),
            _buildNavItem(context, Icons.timeline_rounded, "Activity", 1),
            _buildNavItem(context, Icons.qr_code_scanner_rounded, "Scan Asset", 2),
            _buildNavItem(context, Icons.settings_rounded, "Setting", 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index) {
    final selected = index == selectedIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Icon(icon, color: selected ? Color(0xFF405189) : Colors.grey, size: 28),
          const SizedBox(height: 4),
          Text(label,
            style: TextStyle(
              fontFamily: 'Maison Bold',
              color: selected ? Color(0xFF405189) : Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _pushNotifications = true;

  String _userName = '';
  String _userUsername = '';
  String _lastLoginWIB = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name') ?? '';
    final username = prefs.getString('username') ?? '';
    final lastLogin = prefs.getString('login_time');
    setState(() {
      _userName = name;
      _userUsername = username;
      _lastLoginWIB = lastLogin ?? _getCurrentTimeWIB();
    });
  }

  String _getCurrentTimeWIB() {
    final nowUTC = DateTime.now().toUtc();
    final wibTime = nowUTC.add(const Duration(hours: 7));
    return '${wibTime.year}-${wibTime.month.toString().padLeft(2, '0')}-${wibTime.day.toString().padLeft(2, '0')} ${wibTime.hour.toString().padLeft(2, '0')}:${wibTime.minute.toString().padLeft(2, '0')}:${wibTime.second.toString().padLeft(2, '0')} WIB';
  }

  // ==== NAVIGATION HANDLER ====
  void _onNavTap(int index) {
    if (index == 0) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => WelcomePage()));
    }
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ActivityPage()));
    }
    if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ScanAssetPage()));
    }
    if (index == 3) {
      // Already on settings page
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF405189),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Settings',
              style: TextStyle(
                fontFamily: 'Maison Bold',
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 10),
            // ClipRRect(
            //   // borderRadius: BorderRadius.circular(5),
            //   child: Image.asset(
            //     'assets/images/indocement_logo.png',
            //     width: 40,
            //     height: 40,
            //     fit: BoxFit.cover,
            //   ),
            // ),
          ],
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          SettingsHeader(
            userName: _userName,
            userUsername: _userUsername,
            lastLoginWIB: _lastLoginWIB,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SettingsSectionHeader(title: 'Notifications'),
                  const SizedBox(height: 12),
                  SettingsNotificationCard(
                    notificationsEnabled: _notificationsEnabled,
                    pushNotifications: _pushNotifications,
                    onNotificationsChanged: (val) {
                      setState(() {
                        _notificationsEnabled = val;
                        if (!val) _pushNotifications = false;
                      });
                    },
                    onPushChanged: (val) {
                      setState(() {
                        _pushNotifications = val;
                      });
                    },
                  ),
                  const SizedBox(height: 28),
                  SettingsSectionHeader(title: 'Account'),
                  const SizedBox(height: 12),
                  SettingsAccountCard(
                    userName: _userName,
                    lastLoginWIB: _lastLoginWIB,
                    onProfileTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditProfilePage()));
                    },
                    onLogout: _performLogout,
                  ),
                  const SizedBox(height: 28),
                  SettingsSectionHeader(title: 'About'),
                  const SizedBox(height: 12),
                  const SettingsAboutCard(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: 3, // Setting
        onTap: _onNavTap,
      ),
    );
  }

  void _performLogout() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF405189)),
            ),
            const SizedBox(width: 20),
            const Text(
              'Logging out...',
              style: TextStyle(
                fontFamily: 'Maison Book',
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
    await Future.delayed(const Duration(seconds: 2));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Successfully logged out'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}