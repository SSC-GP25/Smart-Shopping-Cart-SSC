import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/routing/app_router.dart';
import '../../../../../core/themes/light_theme/app_colors_light.dart';

class DoNotHaveAccountWidget extends StatelessWidget {
  const DoNotHaveAccountWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Don\'t have an account?',
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
        ),
        InkWell(
          onTap: () {
            GoRouter.of(context).push(AppRouter.registerView);
          },
          overlayColor: const WidgetStatePropertyAll(
              AppColorsLight.scaffoldBackgroundColor),
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.only(
              top: 8,
              bottom: 8,
              right: 8,
            ),
            child: Text(
              ' Sign Up For Free!',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        )
      ],
    );
  }
}
