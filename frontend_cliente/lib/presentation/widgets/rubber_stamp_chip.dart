import 'dart:math';
import 'package:flutter/material.dart';

class RubberStampChip extends StatelessWidget {
  final String label;
  final Color baseColor;

  const RubberStampChip({super.key, required this.label, required this.baseColor});

  @override
  Widget build(BuildContext context) {
    // Add a slight random rotation to look like it was stamped by hand
    final rotation = (Random().nextDouble() - 0.5) * 0.1;

    return Transform.rotate(
      angle: rotation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: baseColor, width: 2),
          borderRadius: BorderRadius.circular(4),
          // We apply the texture as an overlay
          image: const DecorationImage(
            image: AssetImage('assets/images/stamp_texture.png'),
            fit: BoxFit.cover,
            opacity: 0.8,
            colorFilter: ColorFilter.mode(Colors.white, BlendMode.dstIn),
          ),
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: baseColor,
            fontWeight: FontWeight.bold,
            fontFamily: 'Caveat',
            fontSize: 18,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
