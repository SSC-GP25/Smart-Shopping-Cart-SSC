import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_cart_app/core/routing/app_router.dart';
import 'package:smart_cart_app/core/services/cache_helper.dart';
import 'package:smart_cart_app/core/services/helper_functions.dart';
import 'package:smart_cart_app/features/checkout/data/models/payment_intent_input_model/payment_intent_input_model.dart';
import 'package:smart_cart_app/features/checkout/data/models/transaction_model/transaction_model.dart';
import 'package:smart_cart_app/features/checkout/presentation/manager/checkout_cubit.dart';
import 'package:smart_cart_app/features/checkout/presentation/manager/checkout_states.dart';
import 'package:smart_cart_app/features/home/presentation/manager/home_cubit/home_cubit.dart';

class CustomConsumerButton extends StatelessWidget {
  const CustomConsumerButton({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckoutCubit, CheckoutStates>(
        listener: (context, state) {
      var cubit = CheckoutCubit.get(context);
      if (state is CheckoutSuccess) {
        var userID = CacheHelper.getString(key: CacheHelperKeys.userID);
        var cartID = CacheHelper.getString(key: CacheHelperKeys.cartID);
        cubit
            .getCartProductsForTransaction(HomeCubit.get(context).cartProducts);
        cubit.postUserTransaction(
          transaction: TransactionModel(
            products: cubit.cartProducts,
            paymentMethod:
                cubit.paymentMethodInfo.card!.brand![0].toUpperCase() +
                    cubit.paymentMethodInfo.card!.brand!.substring(1),
            stripeSessionId:
                CacheHelper.getString(key: CacheHelperKeys.stripeSessionId),
            visa: cubit.paymentMethodInfo.card!.last4,
            totalAmount: int.parse(HomeCubit.get(context).totalPrice),
          ),
        );
        HomeCubit.get(context).removeUserFromCart(cartID!, userID!);
        GoRouter.of(context).go(AppRouter.thankYouView);
      } else if (state is CheckoutFailure) {
        Navigator.of(context).pop();
        showCustomSnackBar(
            context: context, message: "Something went wrong", vPadding: 32);
      }
    }, builder: (context, state) {
      var totalPrice = HomeCubit.get(context).totalPrice;
      var cubit = CheckoutCubit.get(context);
      return ElevatedButton(
        onPressed: () {
          if (state is CheckoutLoading ||
              state is CheckoutSuccess ||
              state is CheckoutPostTransactionLoading ||
              state is CheckoutPostTransactionSuccess) {
            return;
          }
          if (cubit.paymentMethodIndex == 0) {
            PaymentIntentInputModel paymentIntentInputModel =
                PaymentIntentInputModel(
              amount: totalPrice,
              currency: "USD",
              customerId: CacheHelper.getString(
                      key: CacheHelperKeys.stripeCustomerId) ??
                  "",
            );
            CheckoutCubit.get(context)
                .makePayment(paymentIntentInputModel: paymentIntentInputModel);
          } else {
            GoRouter.of(context).push(AppRouter.cashPaymentView);
          }
        },
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          backgroundColor: WidgetStateProperty.all(const Color(0xff5b9ee1)),
        ),
        child: state is CheckoutLoading
            ? const SizedBox(
                height: 15,
                width: 15,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      fontFamily: "Carmen",
                    ),
              ),
      );
    });
  }
}
