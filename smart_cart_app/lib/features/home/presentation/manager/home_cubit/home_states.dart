import 'package:smart_cart_app/features/home/data/models/cart_product_model/cart_product_model.dart';

abstract class HomeStates {}

class HomeInitial extends HomeStates {}

class HomeSocketConnectedState extends HomeStates {}

class HomeAddUserToCartLoading extends HomeStates {}

class HomeAddUserToCartFailure extends HomeStates {
  String errMessage;
  HomeAddUserToCartFailure(this.errMessage);
}

class HomeAddUserToCartSuccess extends HomeStates {}

class HomeRemoveUserFromCartLoading extends HomeStates {}

class HomeRemoveUserFromCartFailure extends HomeStates {
  String errMessage;
  HomeRemoveUserFromCartFailure(this.errMessage);
}

class HomeRemoveUserFromCartSuccess extends HomeStates {}

class HomeUserNotConnectedToCartState extends HomeStates {}

class HomeGetScannedProductsLoading extends HomeStates {}

class HomeGetScannedProductsFailure extends HomeStates {
  String errMessage;
  HomeGetScannedProductsFailure(this.errMessage);
}

class HomeGetScannedProductsSuccess extends HomeStates {
  List<CartProductModel> products;
  HomeGetScannedProductsSuccess(this.products);
}

class HomeGetCartProductsLoading extends HomeStates {}

class HomeGetCartProductsFailure extends HomeStates {
  String errMessage;
  HomeGetCartProductsFailure(this.errMessage);
}

class HomeGetCartProductsSuccess extends HomeStates {
  List<CartProductModel> products;
  HomeGetCartProductsSuccess(this.products);
}

class HomeDeleteProductLoading extends HomeStates {}

class HomeDeleteProductFailure extends HomeStates {
  String errMessage;
  HomeDeleteProductFailure(this.errMessage);
}

class HomeDeleteProductSuccess extends HomeStates {}
