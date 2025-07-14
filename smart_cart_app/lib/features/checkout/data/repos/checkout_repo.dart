import 'package:either_dart/either.dart';
import 'package:smart_cart_app/features/checkout/data/models/payment_method_info/payment_method_info.dart';
import '../models/payment_intent_input_model/payment_intent_input_model.dart';

abstract class CheckoutRepo {
  Future<Either<String, PaymentMethodInfo>> makePayment(
      {required PaymentIntentInputModel paymentIntentInputModel});

  Future<Either<String, PaymentMethodInfo>> retrievePaymentInfo(
      {required String clientSecret});

  Future<Either<String, Map<String, dynamic>>> postTransaction(
      {required Map<String, dynamic> transaction});
}
