import 'package:flutter/material.dart';
import 'package:smart_cart_app/core/themes/light_theme/app_colors_light.dart';

class ProfileInfoWidget extends StatelessWidget {
  const ProfileInfoWidget({
    super.key,
    required this.preIcon,
    required this.label,
    required this.value,
  });

  final IconData preIcon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            preIcon,
            color: AppColorsLight.primaryColor,
            size: 26,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(fontFamily: "Carmen", fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(fontFamily: "Carmen", color: Colors.grey),
          ),
          const SizedBox(
            width: 12,
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey,
            size: 20,
          ),
        ],
      ),
    );
  }
}
