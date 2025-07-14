import 'package:flutter/material.dart';
import 'package:smart_cart_app/core/themes/light_theme/app_colors_light.dart';
import 'payment_methods_bottom_sheet.dart';

class CustomCheckoutButton extends StatelessWidget {
  const CustomCheckoutButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          showModalBottomSheet(
            backgroundColor: AppColorsLight.scaffoldBackgroundColor,
            context: context,
            builder: (context) {
              return const PaymentMethodsBottomSheet();
            },
          );
        },
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          backgroundColor: WidgetStateProperty.all(const Color(0xff5b9ee1)),
        ),
        child: Text(
          "Complete Payment",
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                fontWeight: FontWeight.w400,
                color: Colors.white,
                fontFamily: "Carmen",
              ),
        ),
      ),
    );
  }
}
