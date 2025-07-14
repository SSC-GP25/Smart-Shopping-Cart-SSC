import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/routing/app_router.dart';
import '../../../../../core/themes/light_theme/app_colors_light.dart';

class ForgotPasswordWidget extends StatelessWidget {
  const ForgotPasswordWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        InkWell(
          onTap: () {
            GoRouter.of(context).push(AppRouter.passwordRecoveryView);
          },
          overlayColor: const WidgetStatePropertyAll(
            AppColorsLight.scaffoldBackgroundColor,
          ),
          child: Text(
            "Forgot Password?",
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
          ),
        ),
      ],
    );
  }
}
