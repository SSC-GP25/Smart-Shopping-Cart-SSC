import 'package:flutter/material.dart';
import 'package:smart_cart_app/core/themes/light_theme/app_colors_light.dart';

class ThankYouHalfCircle extends StatelessWidget {
  const ThankYouHalfCircle({
    super.key,
    this.left,
    this.right,
  });
  final double? left, right;
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.sizeOf(context).height * 0.16,
      left: left,
      right: right,
      child: const CircleAvatar(
        backgroundColor: AppColorsLight.scaffoldBackgroundColor,
      ),
    );
  }
}
