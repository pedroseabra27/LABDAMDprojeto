import 'package:flutter/material.dart';

class HandDrawnCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const HandDrawnCard({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.transparent,
          image: const DecorationImage(
            image: AssetImage('assets/images/watercolor_card.png'),
            fit: BoxFit.fill, // Stretches the watercolor wash slightly
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(2, 4),
              blurRadius: 8,
            )
          ],
        ),
        // Add padding so content doesn't touch the irregular edges
        padding: const EdgeInsets.all(20),
        child: child,
      ),
    );
  }
}
