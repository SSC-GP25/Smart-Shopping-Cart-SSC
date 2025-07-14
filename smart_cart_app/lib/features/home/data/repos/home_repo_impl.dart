import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:smart_cart_app/core/networking/api/api_consts.dart';
import 'package:smart_cart_app/core/networking/api/api_service.dart';
import 'package:smart_cart_app/core/networking/errors/exceptions.dart';
import 'package:smart_cart_app/core/services/notification_service.dart';
import 'package:smart_cart_app/features/home/data/models/cart_product_model/cart_product_model.dart';
import 'package:smart_cart_app/features/home/data/models/map_model_types.dart';
import 'package:smart_cart_app/features/home/data/models/map_search_product_model/map_search_product_model.dart';
import 'package:smart_cart_app/features/home/data/models/recommendations_model/RecommendedItems.dart';
import 'package:smart_cart_app/features/home/data/repos/home_repo.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class HomeRepoImpl extends HomeRepo {
  final ApiService apiService;
  final IO.Socket socket;
  HomeRepoImpl(this.apiService, this.socket) {
    _setupSocketListeners();
    print("Socket initialized and listeners set up");
  }
  @override
  Future<Either<String, Map<String, dynamic>>> addUserToCart({
    required String cartID,
    required String userID,
  }) async {
    try {
      var response =
          await apiService.addUserToCart(cartID: cartID, userID: userID);
      return Right(response);
    } on ServerException catch (e) {
      return Left(e.errorModel.errMessage);
    }
  }

  @override
  Future<Either<String, Map<String, dynamic>>> removeUserFromCart({
    required String cartID,
    required String userID,
  }) async {
    try {
      var resposeCode =
          await apiService.removeUserFromCart(cartID: cartID, userID: userID);
      return Right(resposeCode!);
    } on ServerException catch (e) {
      return Left(e.errorModel.errMessage);
    }
  }

  final StreamController<Either<String, List<CartProductModel>>>
      _streamController = StreamController.broadcast();
  final StreamController<Either<String, String>> _notificationStreamController =
      StreamController.broadcast();

  void _setupSocketListeners() {
    socket.on(ApiKeys.cartUpdated, (data) {
      try {
        print("🔄 Received cart update from socket");
        List<CartProductModel> updatedProducts = data
            .map<CartProductModel>((item) => CartProductModel.fromJson(item))
            .toList();

        _streamController.add(Right(updatedProducts));
      } on ServerException catch (e) {
        return Left(e.errorModel.errMessage);
      }
    });

    socket.onError((error) {
      print("Socket error: $error");
      _streamController.add(const Left("Error to Connect to server"));
    });
  }

  @override
  Stream<Either<String, List<CartProductModel>>> getScannedProducts() {
    return _streamController.stream;
  }

  @override
  void setupSocketNotificationListeners({required String cartID}) {
    socket.on(ApiKeys.cartalerts + cartID, (data) {
      try {
        print("🔄 Received Notification");
        NotificationService().showNotification(
          title: data["header"],
          body: data["message"],
        );
        // _notificationStreamController.add(Right(updatedProducts));
      } on ServerException catch (e) {
        return Left(e.errorModel.errMessage);
      }
    });

    socket.onError((error) {
      print("Socket error: $error");
      _notificationStreamController.add(Left(error.toString()));
    });
  }

  // @override
  // void disconnectSocket() {
  //   if (socket.connected) {
  //     socket.disconnect();
  //     socket.clearListeners();
  //   }
  //   _streamController.close().then(
  //         (value) => print(
  //             "Socket and stream are closed ================================="),
  //       );
  // }

  @override
  Future<Either<String, List<CartProductModel>>> getCartProducts(
      {required String cartID}) async {
    try {
      var data = await apiService.getCartProducts(cartID: cartID);
      List<CartProductModel> products = [];
      for (var i in data[ApiKeys.results]) {
        products.add(CartProductModel.fromJson(i));
      }
      return Right(products);
    } on ServerException catch (e) {
      return Left(e.errorModel.errMessage);
    }
  }

  @override
  Future<Either<String, int>> deleteProductFromCart(
      {required String productID, required String cartID}) async {
    try {
      var response =
          await apiService.deleteProduct(productID: productID, cartID: cartID);
      return Right(response);
    } on ServerException catch (e) {
      return Left(e.errorModel.errMessage);
    }
  }

  @override
  Future<Either<String, List<RecommendedItems>>> getRecommendations(
      {required String userID}) async {
    try {
      var data = await apiService.getRecommendations(userID: userID);
      List<RecommendedItems> recommendations = [];
      for (var i in data[ApiKeys.recommendedItems]) {
        recommendations.add(RecommendedItems.fromJson(i));
      }
      return Right(recommendations);
    } on ServerException catch (e) {
      return Left(e.errorModel.errMessage);
    }
  }

  @override
  Future<Either<String, List<MapSearchProductModel>>> getSearchedProducts(
      {required String query}) async {
    try {
      var data = await apiService.getSearchedProducts(query: query);
      List<MapSearchProductModel> products = [];
      for (var i in data[ApiKeys.data][ApiKeys.products]) {
        products.add(MapSearchProductModel.fromJson(i));
      }
      return Right(products);
    } on ServerException catch (e) {
      return Left(e.errorModel.errMessage);
    }
  }

  @override
  Future<Either<String, List<List<int>>>> findPath(
      {required Coordinates start, required Coordinates end}) async {
    try {
      var data = await apiService.findPath(start: start, end: end);
      final rawPath = data[ApiKeys.data][ApiKeys.path] as List;
      final path = rawPath
          .map<List<int>>(
              (point) => (point as List).map<int>((e) => e as int).toList())
          .toList();
      return Right(path);
    } on ServerException catch (e) {
      return Left(e.errorModel.errMessage);
    }
  }
}
