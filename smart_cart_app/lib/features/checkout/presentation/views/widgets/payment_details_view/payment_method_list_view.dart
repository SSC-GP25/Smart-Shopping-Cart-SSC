import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_cart_app/features/checkout/presentation/manager/checkout_cubit.dart';
import 'package:smart_cart_app/features/checkout/presentation/manager/checkout_states.dart';

import 'payment_method_item.dart';

class PaymentMethodListView extends StatelessWidget {
  PaymentMethodListView({super.key});

  final List<String> paymentMethods = [
    "assets/images/credit_card.svg",
    "assets/images/cash.svg",
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CheckoutCubit, CheckoutStates>(
        builder: (context, state) {
      var cubit = CheckoutCubit.get(context);
      return SizedBox(
        height: 62.h,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 8,
            children: List.generate(
              paymentMethods.length,
              (index) => GestureDetector(
                onTap: () {
                  cubit.changePaymentMethodIndex(index);
                  // setState(() {
                  //   activeIndex = index;
                  // });
                },
                child: PaymentMethodItem(
                  isActive: cubit.paymentMethodIndex == index,
                  image: paymentMethods[index],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
