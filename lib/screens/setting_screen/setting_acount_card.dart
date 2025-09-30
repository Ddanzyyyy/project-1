import 'package:flutter/material.dart';

class SettingsAccountCard extends StatelessWidget {
  final String userName;
  final String lastLoginWIB;
  final VoidCallback onProfileTap;
  final VoidCallback onLogout;

  const SettingsAccountCard({
    Key? key,
    required this.userName,
    required this.lastLoginWIB,
    required this.onProfileTap,
    required this.onLogout,
  }) : super(key: key);

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: Row(
          children: [
            const Icon(Icons.logout, color: Colors.red, size: 24),
            const SizedBox(width: 8),
            const Text(
              'Log Out',
              style: TextStyle(
                fontFamily: 'Maison Bold',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.red,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to log out?',
              style: TextStyle(
                fontFamily: 'Maison Book',
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, color: Color(0xFF405189), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontFamily: 'Maison Bold',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF405189),
                          ),
                        ),
                        Text(
                          'Last login: $lastLoginWIB',
                          style: TextStyle(
                            fontFamily: 'Maison Book',
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Maison Book',
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Log Out',
              style: TextStyle(
                fontFamily: 'Maison Bold',
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF405189).withOpacity(0.13),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.person_outline,
                color: Color(0xFF405189),
                size: 22,
              ),
            ),
            title: const Text(
              'Info Profile',
              style: TextStyle(
                fontFamily: 'Maison Bold',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF405189),
              ),
            ),
            subtitle: Text(
              'Information about your profile',
              style: TextStyle(
                fontFamily: 'Maison Book',
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF405189),
              size: 17,
            ),
            onTap: onProfileTap,
          ),
          const Divider(height: 1, indent: 60),
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.logout,
                color: Colors.red,
                size: 22,
              ),
            ),
            title: const Text(
              'Log Out',
              style: TextStyle(
                fontFamily: 'Maison Bold',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.red,
              ),
            ),
            subtitle: Text(
              'Sign out from your account',
              style: TextStyle(
                fontFamily: 'Maison Book',
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.red,
              size: 17,
            ),
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }
}