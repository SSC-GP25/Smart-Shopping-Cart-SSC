import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:smart_cart_app/core/services/cache_helper.dart';
import 'package:smart_cart_app/features/home/presentation/manager/home_cubit/home_cubit.dart';

class ConnectedCartCustomAppBar extends StatelessWidget {
  const ConnectedCartCustomAppBar({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "Your Cart",
          style: Theme.of(context)
              .textTheme
              .headlineMedium!
              .copyWith(fontFamily: "Carmen"),
        ),
        const Spacer(),
        InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            QuickAlert.show(
              context: context,
              type: QuickAlertType.warning,
              title: "Are you sure you want to leave the cart ?",
              confirmBtnColor: Colors.red,
              headerBackgroundColor: Colors.red,
              showCancelBtn: true,
              onCancelBtnTap: () => Navigator.pop(context),
              onConfirmBtnTap: () {
                var userID = CacheHelper.getString(key: CacheHelperKeys.userID);
                var cartID = CacheHelper.getString(key: CacheHelperKeys.cartID);
                HomeCubit.get(context).removeUserFromCart(cartID!, userID!);
                Navigator.pop(context);
              },
            );
          },
          child: const Padding(
            padding: EdgeInsets.only(left: 8, right: 8),
            child: Icon(
              Icons.login_rounded,
              color: Colors.red,
              size: 28,
            ),
          ),
        )
      ],
    );
  }
}
