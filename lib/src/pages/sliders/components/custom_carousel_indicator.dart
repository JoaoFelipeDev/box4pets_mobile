import 'package:Box4Pets/config/app_color.dart';
import 'package:flutter/material.dart';

class CustomCarouselIndicator extends StatelessWidget {
  final int itemCount;
  final int currentIndex;

  CustomCarouselIndicator(
      {required this.itemCount, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        itemCount,
        (index) {
          return Container(
            width: currentIndex == index ? 30 : 10,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: currentIndex == index ? AppColor.orange : Colors.white,
            ),
          );
        },
      ),
    );
  }
}
