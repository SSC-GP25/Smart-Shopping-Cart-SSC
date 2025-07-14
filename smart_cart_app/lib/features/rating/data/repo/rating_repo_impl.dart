import 'package:either_dart/either.dart';
import 'package:smart_cart_app/core/networking/api/api_consts.dart';
import 'package:smart_cart_app/features/rating/data/models/order_model/order_model.dart';
import 'package:smart_cart_app/features/rating/data/repo/rating_repo.dart';
import '../../../../core/networking/api/api_service.dart';
import '../../../../core/networking/errors/exceptions.dart';

class RatingRepoImpl extends RatingRepo {
  final ApiService apiService;

  RatingRepoImpl(this.apiService);

  @override
  Future<Either<String, List<OrderModel>>> getUserOrders() async {
    try {
      var response = await apiService.getUserOrders();
      List<OrderModel> orders = [];
      for (var i in response[ApiKeys.data][ApiKeys.userOrders]) {
        orders.add(OrderModel.fromJson(i));
      }
      return Right(orders);
    } on ServerException catch (e) {
      return Left(e.errorModel.errMessage);
    }
  }

  @override
  Future<Either<String, Map<String, dynamic>>> postUserRatings(
      {required List<Map<String, dynamic>> ratings,
      required String orderID}) async {
    try {
      var response =
          await apiService.postRatings(ratings: ratings, orderID: orderID);
      return Right(response);
    } on ServerException catch (e) {
      return Left(e.errorModel.errMessage);
    }
  }
}
