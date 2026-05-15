import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Standardized loader for the app.
///
/// Default behaviour: fills the parent area and centers the dog animation
/// slightly above geometric center (accounting for the overlaid bottom
/// navigation bar so the loader lands on the *visual* center of the screen).
///
/// `inline: true` skips the fill — use inside a Column with sibling content.
class Box4PetsLoader extends StatelessWidget {
  final double size;
  final bool inline;

  const Box4PetsLoader({
    super.key,
    this.size = 140,
    this.inline = false,
  });

  @override
  Widget build(BuildContext context) {
    final lottie = SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        'assets/Moody Dog.json',
        fit: BoxFit.contain,
        repeat: true,
      ),
    );

    if (inline) return lottie;

    return Padding(
      padding: const EdgeInsets.only(bottom: 110),
      child: Center(child: lottie),
    );
  }
}
