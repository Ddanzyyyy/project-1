import 'package:flutter/material.dart';

class ScanAssetTabButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const ScanAssetTabButton({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedColor = const Color(0xFF405189);
    final bgColor = isSelected ? selectedColor : Colors.white;
    final contentColor = isSelected ? Colors.white : selectedColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? null
              : Border.all(color: selectedColor.withOpacity(0.15), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // render icon only when provided
            if (icon != null) ...[
              Icon(icon, size: 18, color: isSelected ? Colors.white : Colors.grey),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: contentColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}