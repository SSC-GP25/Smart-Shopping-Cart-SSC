import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:smart_cart_app/core/services/cache_helper.dart';

class CashPaymentViewBody extends StatelessWidget {
  const CashPaymentViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(60.0),
        child: PrettyQrView.data(
          data:
              CacheHelper.getString(key: CacheHelperKeys.cartID) ?? "Not Found",
        ),
      ),
    );
  }
}
