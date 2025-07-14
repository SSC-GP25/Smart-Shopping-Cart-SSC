import 'package:flutter/material.dart';
import 'package:smart_cart_app/features/checkout/presentation/views/widgets/cash_payment_view/cash_payment_view_body.dart';

class CashPaymentView extends StatelessWidget {
  const CashPaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Pay With Cash",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      body: const CashPaymentViewBody(),
    );
  }
}
