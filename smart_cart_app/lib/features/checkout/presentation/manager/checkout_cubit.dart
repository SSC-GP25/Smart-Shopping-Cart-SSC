import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:smart_cart_app/features/checkout/data/models/payment_intent_input_model/payment_intent_input_model.dart';
import 'package:smart_cart_app/features/checkout/data/models/payment_method_info/payment_method_info.dart';
import 'package:smart_cart_app/features/checkout/data/models/transaction_model/products.dart';
import 'package:smart_cart_app/features/checkout/data/repos/checkout_repo.dart';
import 'package:smart_cart_app/features/home/data/models/cart_product_model/cart_product_model.dart';
import '../../data/models/transaction_model/transaction_model.dart';
import 'checkout_states.dart';

class CheckoutCubit extends Cubit<CheckoutStates> {
  CheckoutCubit(this.checkoutRepo) : super(CheckoutInitial());

  static CheckoutCubit get(context) => BlocProvider.of(context);
  final CheckoutRepo checkoutRepo;
  PaymentMethodInfo paymentMethodInfo = PaymentMethodInfo();
  String paymentId = "";
  late String currentDate, currentTime;
  List<Products> cartProducts = [];
  int paymentMethodIndex = 0;

  void changePaymentMethodIndex(int index) {
    paymentMethodIndex = index;
    emit(CheckoutChangePaymentMethodIndexState());
  }

  Future makePayment(
      {required PaymentIntentInputModel paymentIntentInputModel}) async {
    emit(CheckoutLoading());
    var data = await checkoutRepo.makePayment(
        paymentIntentInputModel: paymentIntentInputModel);
    data.fold((failure) {
      print("Checkout Failure: $failure");
      emit(CheckoutFailure(failure));
    }, (response) {
      paymentMethodInfo = response;
      getCurrentTimeDate();
      emit(CheckoutSuccess(response));
    });
  }

  getCurrentTimeDate() {
    DateTime now = DateTime.now();
    currentDate = DateFormat('MM/dd/yyyy').format(now);
    currentTime = DateFormat('hh:mm a').format(now);
  }

  Future postUserTransaction({required TransactionModel transaction}) async {
    emit(CheckoutPostTransactionLoading());
    Map<String, dynamic> transactionJson = transaction.toJson();
    var data = await checkoutRepo.postTransaction(transaction: transactionJson);
    data.fold((failure) {
      emit(CheckoutPostTransactionFailure(failure));
    }, (response) {
      emit(CheckoutPostTransactionSuccess());
    });
  }

  void getCartProductsForTransaction(List<CartProductModel> cartItems) {
    cartProducts = cartItems.map((cartItem) {
      return Products(
        productID: cartItem.productID!.id,
        quantity: cartItem.quantity,
      );
    }).toList();
  }
}
