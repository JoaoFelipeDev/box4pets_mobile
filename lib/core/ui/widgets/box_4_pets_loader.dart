import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Box4PetsLoader extends StatelessWidget {
  const Box4PetsLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.horizontalRotatingDots(
          color: Colors.white, size: 60),
    );
  }
}
