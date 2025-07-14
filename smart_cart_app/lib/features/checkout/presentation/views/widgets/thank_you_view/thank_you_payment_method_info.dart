import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smart_cart_app/features/checkout/presentation/manager/checkout_cubit.dart';
import 'package:smart_cart_app/features/checkout/presentation/manager/checkout_states.dart';

class ThankYouPaymentMethodInfo extends StatelessWidget {
  const ThankYouPaymentMethodInfo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CheckoutCubit, CheckoutStates>(
        builder: (context, state) {
      var cubit = CheckoutCubit.get(context);
      if (state is CheckoutSuccess || state is CheckoutPostTransactionSuccess) {
        return Container(
          height: 80.h,
          padding: const EdgeInsets.all(20),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16,
            children: [
              SvgPicture.asset("assets/images/credit_card.svg"),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Credit Card",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    "${cubit.paymentMethodInfo.card!.brand!.toUpperCase()} ${cubit.paymentMethodInfo.card!.last4}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              )
            ],
          ),
        );
      }
      return const Center(
        child: SizedBox(child: CircularProgressIndicator()),
      );
    });
  }
}
