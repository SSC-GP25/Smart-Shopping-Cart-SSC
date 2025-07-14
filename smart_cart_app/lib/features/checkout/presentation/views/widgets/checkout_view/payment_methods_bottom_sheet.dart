import 'package:flutter/material.dart';
import 'package:smart_cart_app/features/checkout/presentation/views/widgets/checkout_view/custom_consumer_button.dart';
import '../payment_details_view/payment_method_list_view.dart';

class PaymentMethodsBottomSheet extends StatelessWidget {
  const PaymentMethodsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        spacing: 16,
        mainAxisSize: MainAxisSize.min,
        children: [
          PaymentMethodListView(),
          const SizedBox(
            width: double.infinity,
            child: CustomConsumerButton(title: "Continue"),
          ),
        ],
      ),
    );
  }
}
