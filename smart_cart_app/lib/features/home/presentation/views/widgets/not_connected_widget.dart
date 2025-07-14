import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_cart_app/core/routing/app_router.dart';
import 'package:smart_cart_app/core/services/helper_functions.dart';
import 'package:smart_cart_app/core/themes/light_theme/app_colors_light.dart';
import 'package:smart_cart_app/features/authentication/presentation/manager/auth_cubit/auth_cubit.dart';
import 'package:smart_cart_app/features/home/presentation/views/widgets/custom_home_app_bar.dart';

class NotConnectedWidget extends StatelessWidget {
  const NotConnectedWidget({
    super.key,
    required this.showSnackbar,
  });
  final bool showSnackbar;
  @override
  Widget build(BuildContext context) {
    String? userName = context.read<AuthCubit>().loginModel?.name ?? "Customer";
    if (showSnackbar) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showCustomSnackBar(
          context: context,
          message: "Sorry, This cart is in use",
          vPadding: 16,
        );
      });
    }
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            CustomHomeAppBar(title: "Hello, $userName"),
            const Spacer(),
            SvgPicture.asset(
              "assets/images/qr_code.svg",
              width: MediaQuery.sizeOf(context).width * 0.4,
            ),
            Text(
              "You're not Connected to any cart, Click This Button to Scan The Cart",
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontFamily: "Carmen",
                  fontWeight: FontWeight.w600,
                  color: AppColorsLight.secondaryColor),
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
              onPressed: () {
                GoRouter.of(context).push(AppRouter.scanQRCodeView);
              },
              style: ButtonStyle(
                overlayColor: WidgetStatePropertyAll(
                  Colors.black.withAlpha(15),
                ),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                backgroundColor: WidgetStateProperty.all(
                  const Color(0xff5b9ee1),
                ),
              ),
              child: Text(
                "Scan QR Code",
                style: Theme.of(context)
                    .textTheme
                    .displaySmall!
                    .copyWith(fontFamily: "Carmen", color: Colors.white),
              ),
            ),
            const Spacer()
          ],
        ),
      ),
    );
  }
}
