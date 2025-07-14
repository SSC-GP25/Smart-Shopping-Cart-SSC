import 'package:flutter/material.dart';
import 'package:smart_cart_app/features/rating/presentation/views/widgets/rate_products_view_body.dart';

class RateProductsView extends StatelessWidget {
  const RateProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: RateProductsViewBody(),
    );
  }
}
