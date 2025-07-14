import 'package:either_dart/either.dart';
import '../models/order_model/order_model.dart';

abstract class RatingRepo {
  Future<Either<String, List<OrderModel>>> getUserOrders();
  Future<Either<String, Map<String, dynamic>>> postUserRatings(
      {required List<Map<String, dynamic>> ratings, required String orderID});
}
