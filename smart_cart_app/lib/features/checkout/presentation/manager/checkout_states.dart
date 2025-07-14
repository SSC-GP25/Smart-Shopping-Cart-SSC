import 'package:smart_cart_app/features/checkout/data/models/payment_method_info/payment_method_info.dart';

abstract class CheckoutStates {}

class CheckoutInitial extends CheckoutStates {}

class CheckoutChangePaymentMethodIndexState extends CheckoutStates {}

class CheckoutLoading extends CheckoutStates {}

class CheckoutFailure extends CheckoutStates {
  String errMessage;

  CheckoutFailure(this.errMessage);
}

class CheckoutSuccess extends CheckoutStates {
  PaymentMethodInfo paymentMethodInfo;

  CheckoutSuccess(this.paymentMethodInfo);
}

class CheckoutRetrievePaymentMethodLoading extends CheckoutStates {}

class CheckoutRetrievePaymentMethodFailure extends CheckoutStates {
  String errMessage;

  CheckoutRetrievePaymentMethodFailure(this.errMessage);
}

class CheckoutRetrievePaymentMethodSuccess extends CheckoutStates {
  PaymentMethodInfo paymentMethodInfo;

  CheckoutRetrievePaymentMethodSuccess(this.paymentMethodInfo);
}

class CheckoutPostTransactionLoading extends CheckoutStates {}

class CheckoutPostTransactionFailure extends CheckoutStates {
  String errMessage;

  CheckoutPostTransactionFailure(this.errMessage);
}

class CheckoutPostTransactionSuccess extends CheckoutStates {}
