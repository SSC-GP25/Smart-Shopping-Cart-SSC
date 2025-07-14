import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smart_cart_app/core/themes/light_theme/app_colors_light.dart';
import '../../manager/home_cubit/home_cubit.dart';
import 'connected_cart_custom_appbar.dart';

class EmptyCartWidget extends StatelessWidget {
  const EmptyCartWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    HomeCubit.get(context).initSocket();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Column(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConnectedCartCustomAppBar(),
                SizedBox(
                  height: 12,
                ),
                Divider(
                  thickness: 0.5,
                  color: Colors.grey,
                ),
              ],
            ),
            const Spacer(
              flex: 1,
            ),
            SvgPicture.asset(
              "assets/images/empty_cart.svg",
              width: MediaQuery.sizeOf(context).width * 0.4,
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              "Your cart is empty, Hurry up and get some good products",
              style: Theme.of(context).textTheme.displayMedium!.copyWith(
                  fontFamily: "Carmen", color: AppColorsLight.secondaryColor),
              textAlign: TextAlign.center,
            ),
            const Spacer(
              flex: 1,
            ),
          ],
        ),
      ),
    );
  }
}
