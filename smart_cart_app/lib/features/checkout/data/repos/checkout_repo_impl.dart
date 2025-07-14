import 'package:either_dart/either.dart';
import 'package:smart_cart_app/core/services/stripe_service.dart';
import 'package:smart_cart_app/features/checkout/data/models/payment_intent_input_model/payment_intent_input_model.dart';
import 'package:smart_cart_app/features/checkout/data/models/payment_method_info/payment_method_info.dart';
import '../../../../core/networking/errors/exceptions.dart';
import 'checkout_repo.dart';

class CheckoutRepoImpl extends CheckoutRepo {
  StripeService stripeService;

  CheckoutRepoImpl(this.stripeService);

  @override
  Future<Either<String, PaymentMethodInfo>> makePayment(
      {required PaymentIntentInputModel paymentIntentInputModel}) async {
    try {
      var paymentMethodInfo = await stripeService.makePayment(
          paymentIntentInputModel: paymentIntentInputModel);
      return Right(paymentMethodInfo);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, PaymentMethodInfo>> retrievePaymentInfo(
      {required String clientSecret}) async {
    try {
      var paymentMethodInfo =
          await stripeService.retrievePaymentInfo(clientSecret);
      return Right(paymentMethodInfo);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Map<String, dynamic>>> postTransaction(
      {required Map<String, dynamic> transaction}) async {
    try {
      var response =
          await stripeService.postUserTransaction(transaction: transaction);
      return Right(response);
    } on ServerException catch (e) {
      return Left(e.errorModel.errMessage);
    }
  }
}
