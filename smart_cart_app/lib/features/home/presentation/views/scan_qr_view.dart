import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smart_cart_app/core/services/cache_helper.dart';
import 'package:smart_cart_app/features/home/presentation/manager/home_cubit/home_cubit.dart';

class ScanQrView extends StatelessWidget {
  ScanQrView({super.key});
  final String? userID = CacheHelper.getString(key: CacheHelperKeys.userID);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MobileScanner(
        controller: MobileScannerController(
            detectionSpeed: DetectionSpeed.noDuplicates),
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          String cartID = "";
          for (final barcode in barcodes) {
            cartID += barcode.displayValue!;
          }
          HomeCubit.get(context).connectUserToCart(cartID, userID!);
          Navigator.pop(context);
        },
      ),
    );
  }
}
