import 'package:either_dart/either.dart';
import 'package:smart_cart_app/features/home/data/models/cart_product_model/cart_product_model.dart';
import 'package:smart_cart_app/features/home/data/models/map_model_types.dart';
import 'package:smart_cart_app/features/home/data/models/map_search_product_model/map_search_product_model.dart';
import 'package:smart_cart_app/features/home/data/models/recommendations_model/RecommendedItems.dart';

abstract class HomeRepo {
  Future<Either<String, Map<String, dynamic>>> addUserToCart(
      {required String cartID, required String userID});

  Future<Either<String, Map<String, dynamic>>> removeUserFromCart(
      {required String cartID, required String userID});

  Future<Either<String, List<RecommendedItems>>> getRecommendations(
      {required String userID});

  Future<Either<String, List<List<int>>>> findPath({required Coordinates start, required Coordinates end});

  Stream<Either<String, List<CartProductModel>>> getScannedProducts();
  void setupSocketNotificationListeners({required String cartID});

  // void disconnectSocket();
  Future<Either<String, List<CartProductModel>>> getCartProducts(
      {required String cartID});

  Future<Either<String, int?>> deleteProductFromCart(
      {required String productID, required String cartID});
  Future<Either<String, List<MapSearchProductModel>>> getSearchedProducts(
      {required String query});
}
