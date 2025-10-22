import 'package:flutter/material.dart';

class SettingsHeader extends StatelessWidget {
  final String userName;
  final String userUsername;
  final String lastLoginWIB;

  const SettingsHeader({
    Key? key,
    required this.userName,
    required this.userUsername,
    required this.lastLoginWIB,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(5, 5, 20, 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.grey[300],
            child: const Icon(
              Icons.person,
              color: Color(0xFF868686),
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName.isNotEmpty ? userName : 'Loading...',
                  style: const TextStyle(
                    fontFamily: 'Maison Bold',
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  userUsername.isNotEmpty ? '@$userUsername' : '',
                  style: const TextStyle(
                    fontFamily: 'Maison Book',
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        'Last login: $lastLoginWIB',
                        style: const TextStyle(
                          fontFamily: 'Maison Book',
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
