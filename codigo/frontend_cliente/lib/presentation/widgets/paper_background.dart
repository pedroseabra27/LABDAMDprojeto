import 'package:flutter/material.dart';

class PaperBackground extends StatelessWidget {
  final Widget child;

  const PaperBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.5,
          colors: [
            Color(0xFFF9F6F0), // Sand light
            Color(0xFFEBE3D5), // Sand darker edges
          ],
        ),
      ),
      child: child,
    );
  }
}
