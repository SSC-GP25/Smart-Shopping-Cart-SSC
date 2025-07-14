import 'package:flutter/material.dart';
import 'package:smart_cart_app/features/checkout/presentation/views/widgets/checkout_view/checkout_cart_view_body.dart';

class CheckoutCartView extends StatelessWidget {
  const CheckoutCartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "My Cart",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: const CheckoutCartViewBody(),
    );
  }
}
