import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_cart_app/features/home/presentation/manager/home_cubit/home_cubit.dart';
import 'package:smart_cart_app/features/home/presentation/manager/home_cubit/home_states.dart';

import 'custom_checkout_button.dart';
import 'order_info_item.dart';
import 'total_price_widget.dart';

class CheckoutCartViewBody extends StatelessWidget {
  const CheckoutCartViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeStates>(
      listener: (context, state) {
        if (state is HomeGetScannedProductsSuccess) {}
      },
      builder: (context, state) {
        var cubit = HomeCubit.get(context);
        cubit.getTotalPrice();
        cubit.getTotalDiscount();
        final String orderSubtotal = cubit.orderSubtotal;
        final String totalDiscount = cubit.totalDiscount;
        final String totalPrice = cubit.totalPrice;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 15,
            children: [
              Expanded(
                child: Image.asset(
                  "assets/images/cart_products.png",
                ),
              ),
              OrderInfoItem(
                  title: "Order Subtotal", value: "$orderSubtotal.00 L.E"),
              OrderInfoItem(title: "Discount", value: "$totalDiscount.00 L.E"),
              const Divider(thickness: 0.5, color: Colors.grey),
              TotalPriceWidget(price: "$totalPrice.00 L.E"),
              const CustomCheckoutButton(),
              const SizedBox(
                height: 5,
              ),
            ],
          ),
        );
      },
    );
  }
}
