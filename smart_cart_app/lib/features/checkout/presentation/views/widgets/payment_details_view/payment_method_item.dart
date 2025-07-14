import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smart_cart_app/core/themes/light_theme/app_colors_light.dart';

class PaymentMethodItem extends StatelessWidget {
  const PaymentMethodItem({
    super.key,
    required this.isActive,
    required this.image,
  });
  final bool isActive;
  final String image;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      height: 60.h,
      width: 100.w,
      duration: const Duration(milliseconds: 300),
      decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: isActive ? 1.5 : 1,
              color: isActive
                  ? AppColorsLight.primaryColor
                  : AppColorsLight.secondaryColor,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          color: Colors.white,
          shadows: [
            isActive
                ? const BoxShadow(
                    color: AppColorsLight.primaryColor,
                    blurRadius: 4,
                    offset: Offset(0, 0),
                    spreadRadius: 0)
                : const BoxShadow()
          ]),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        child: SizedBox(
          width: 50.w,
          child: SvgPicture.asset(
            fit: BoxFit.scaleDown,
            image,
          ),
        ),
      ),
    );
  }
}
