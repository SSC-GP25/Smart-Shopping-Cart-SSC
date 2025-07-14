import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_cart_app/core/routing/app_router.dart';
import 'package:smart_cart_app/features/home/presentation/manager/home_cubit/home_cubit.dart';

class CheckoutButton extends StatelessWidget {
  const CheckoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (HomeCubit.get(context).cartProducts.isNotEmpty) {
            GoRouter.of(context).push(AppRouter.checkoutCartView);
          }
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
          "Go to Payment",
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
