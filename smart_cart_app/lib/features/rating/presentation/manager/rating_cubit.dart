import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_cart_app/features/rating/data/models/order_model/order_model.dart';
import 'package:smart_cart_app/features/rating/data/models/order_model/product.dart';
import 'package:smart_cart_app/features/rating/data/repo/rating_repo.dart';

import '../../data/models/rating_model/rating_model.dart';

part 'rating_state.dart';

class RatingCubit extends Cubit<RatingState> {
  RatingCubit(this.ratingRepo) : super(RatingInitial());

  static RatingCubit get(context) => BlocProvider.of(context);
  final RatingRepo ratingRepo;
  List<OrderModel> orders = [];
  OrderModel currentOrder = OrderModel();
  List<Product> ordersProducts = [];
  List<RatingModel> ratingList = [];

  Future<void> gerUserOrders() async {
    emit(RatingGetUserOrdersLoading());
    var result = await ratingRepo.getUserOrders();
    result.fold((failure) {
      emit(RatingGetUserOrdersFailure(failure));
    }, (result) {
      orders = result;
      emit(RatingGetUserOrdersSuccess(result));
    });
  }

  void initRatingList(List<Product> products) {
    ratingList = products.map((product) {
      return RatingModel(productID: product.productId, userRating: 3);
    }).toList();
  }

  getUserOrderProducts({required int index}) {
    ordersProducts = orders[index].products!;
  }

  setCurrentOrder({required OrderModel order}) {
    currentOrder = order;
  }

  Future<void> postUserRatings(
      {required List<RatingModel> ratings, required String orderID}) async {
    emit(RatingPostUserRatingsLoading());
    List<Map<String, dynamic>> ratingsJson =
        ratingList.map((rating) => rating.toJson()).toList();
    var result = await ratingRepo.postUserRatings(
        ratings: ratingsJson, orderID: orderID);
    result.fold((failure) {
      emit(RatingPostUserRatingsFailure(failure));
    }, (result) {
      emit(RatingPostUserRatingsSuccess());
    });
  }

  void updateRatingList(String productID, int userRating) {
    int index =
        ratingList.indexWhere((rating) => rating.productID == productID);

    if (index != -1) {
      ratingList[index] =
          RatingModel(productID: productID, userRating: userRating);
    } else {
      ratingList.add(RatingModel(productID: productID, userRating: userRating));
    }
  }
}
