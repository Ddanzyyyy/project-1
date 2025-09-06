import 'package:flutter/material.dart';

class SettingsSectionHeader extends StatelessWidget {
  final String title;

  const SettingsSectionHeader({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Maison Bold',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF405189),
      ),
    );
  }
}