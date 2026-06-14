import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color baseColor;

  const StatusBadge({super.key, required this.label, required this.baseColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: baseColor.withOpacity(0.3), width: 1),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: baseColor,
          fontWeight: FontWeight.w600,
          fontFamily: 'sans-serif', // Falls back to default sans-serif
          fontSize: 12,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
