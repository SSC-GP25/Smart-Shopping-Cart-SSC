import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:smart_cart_app/core/services/cache_helper.dart';
import 'package:smart_cart_app/features/checkout/presentation/manager/checkout_cubit.dart';
import 'package:smart_cart_app/features/checkout/presentation/views/widgets/checkout_view/total_price_widget.dart';
import 'package:smart_cart_app/features/home/presentation/manager/home_cubit/home_cubit.dart';

import 'thank_you_payment_method_info.dart';

class ThankYouContainer extends StatelessWidget {
  const ThankYouContainer({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    var totalPrice = HomeCubit.get(context).totalPrice;
    var currentDate = CheckoutCubit.get(context).currentDate;
    var currentTime = CheckoutCubit.get(context).currentTime;
    var paymentID = CacheHelper.getString(key: CacheHelperKeys.stripeSessionId);
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.8,
      padding: const EdgeInsets.only(right: 28, left: 28, top: 44, bottom: 8),
      decoration: ShapeDecoration(
        color: const Color(0xffededed),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Column(
        spacing: MediaQuery.sizeOf(context).height * 0.018,
        children: [
          Text(
            "Thank You!",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text(
            "Your Transaction was Successful",
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(fontWeight: FontWeight.w500),
          ),
          SizedBox(
            height: 5.h,
          ),
          Row(
            children: [
              Text(
                "Date",
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const Spacer(),
              Text(
                currentDate,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          Row(
            children: [
              Text(
                "Time",
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const Spacer(),
              Text(
                currentTime,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const Divider(
            thickness: 0.5,
            color: Colors.grey,
            height: 30,
          ),
          TotalPriceWidget(price: "$totalPrice.00 L.E"),
          SizedBox(
            height: 2.h,
          ),
          const Expanded(child: ThankYouPaymentMethodInfo()),
          SizedBox(
            height: 20.h,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 5,
                  children: [
                    SizedBox(
                      height: 70,
                      child: PrettyQrView.data(data: paymentID ?? "QR Code"),
                    ),
                    Text(
                      "Exit QR Code",
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
                Container(
                  height: 60.h,
                  margin: EdgeInsets.only(bottom: 20.h),
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(width: 1.5, color: Colors.green),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: const Color(0xffededed),
                  ),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 25.w, vertical: 12.h),
                    child: Center(
                      child: Text(
                        "PAID",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(color: Colors.green),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
