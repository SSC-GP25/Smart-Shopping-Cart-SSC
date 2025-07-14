import 'package:dio/dio.dart';
import 'package:smart_cart_app/core/networking/api/api_consts.dart';
import 'package:smart_cart_app/core/networking/api/api_consumer.dart';
import 'package:smart_cart_app/features/checkout/data/models/payment_intent_input_model/payment_intent_input_model.dart';
import 'package:smart_cart_app/features/home/data/models/map_model_types.dart';

class ApiService {
  final ApiConsumer api;

  ApiService(this.api);

  signUp({
    required String name,
    required String email,
    required String password,
    required String gender,
    required String birthdate,
  }) async {
    var response = await api.post(
      '${ApiConsts.apiBaseUrl}${ApiConsts.auth}${ApiConsts.signUp}',
      data: {
        ApiKeys.name: name,
        ApiKeys.email: email,
        ApiKeys.password: password,
        ApiKeys.gender: gender,
        ApiKeys.birthdate: birthdate,
      },
    );
    return response;
  }

  verifyEmail({
    required String code,
  }) async {
    var response = await api.post(
      '${ApiConsts.apiBaseUrl}${ApiConsts.auth}${ApiConsts.verifyEmail}',
      data: {
        ApiKeys.code: code,
      },
    );
    return response;
  }

  logIn({
    required String email,
    required String password,
  }) async {
    var response = await api.post(
      '${ApiConsts.apiBaseUrl}${ApiConsts.auth}${ApiConsts.login}',
      data: {
        ApiKeys.email: email,
        ApiKeys.password: password,
      },
    );
    return response;
  }

  logOut() async {
    var response = await api
        .post('${ApiConsts.apiBaseUrl}${ApiConsts.auth}${ApiConsts.logout}');
    return response;
  }

  getCategories() async {
    var response = await api
        .get('${ApiConsts.apiBaseUrl}${ApiConsts.user}${ApiConsts.categories}');
    return response;
  }

  postCategories(List<String> categories) async {
    var response = await api.post(
        '${ApiConsts.apiBaseUrl}${ApiConsts.user}${ApiConsts.likedCategories}',
        data: {ApiKeys.likedCategories: categories});
    return response;
  }

  getRecommendations({required String userID}) async {
    var response = await api.get(
      '${ApiConsts.apiBaseUrl}${ApiConsts.recommendations}${ApiConsts.huggingFace}',
      queryParameters: {ApiKeys.customerId: userID},
    );
    return response;
  }

  getSearchedProducts({required String query}) async {
    var response = await api.get(
      '${ApiConsts.apiBaseUrl}${ApiConsts.products}',
      queryParameters: {ApiKeys.search: query},
    );
    return response;
  }

  addUserToCart({required String cartID, required String userID}) async {
    var response = await api.patch(
      '${ApiConsts.apiBaseUrl}${ApiConsts.cart}$cartID/${ApiConsts.addUserToCart}',
      data: {ApiKeys.userID: userID},
    );
    return response;
  }

  findPath({
    required Coordinates start,
    required Coordinates end,
  }) async {
    var response = await api.post(
      '${ApiConsts.apiBaseUrl}${ApiConsts.navigation}${ApiConsts.findPath}',
      data: {
        ApiKeys.start: {"x": start.x, "y": start.y},
        ApiKeys.end: {"x": end.x, "y": end.y},
      },
    );
    return response;
  }

  removeUserFromCart({required String cartID, required String userID}) async {
    var response = await api.patch(
      '${ApiConsts.apiBaseUrl}${ApiConsts.cart}$cartID/${ApiConsts.removeUserFromCart}',
      data: {ApiKeys.userID: userID},
    );
    return response;
  }

  Future<Map<String, dynamic>> getCartProducts({required String cartID}) async {
    var response = await api.get(
      '${ApiConsts.apiBaseUrl}${ApiConsts.cart}$cartID/${ApiConsts.products}',
    );
    return response;
  }

  deleteProduct({required String productID, required String cartID}) async {
    var response = await api.delete(
      '${ApiConsts.apiBaseUrl}${ApiConsts.cart}$cartID/${ApiConsts.deleteProductFromCart}',
      data: {ApiKeys.productID: productID},
    );
    return response;
  }

  createPaymentIntent({
    required PaymentIntentInputModel paymentIntentInputModel,
  }) async {
    var response = await api.post(
        "${ApiConsts.stripeBaseUrl}${ApiConsts.stripePaymentIntent}",
        data: paymentIntentInputModel.toJson(),
        token: ApiConsts.stripeToken,
        headers: {
          "authorization": "Bearer ${ApiConsts.stripeToken}",
        },
        contentType: Headers.formUrlEncodedContentType);
    return response;
  }

  createEphemeralKey({
    required String customerId,
  }) async {
    var response = await api.post(
        "${ApiConsts.stripeBaseUrl}${ApiConsts.stripeEphemeralKey}",
        data: {"customer": customerId},
        token: ApiConsts.stripeToken,
        contentType: Headers.formUrlEncodedContentType,
        headers: {
          "authorization": "Bearer ${ApiConsts.stripeToken}",
          "Stripe-Version": "2025-01-27.acacia"
        });
    return response;
  }

  retrievePaymentMethod({
    required String paymentId,
  }) async {
    var response = await api.get(
      "${ApiConsts.stripeBaseUrl}${ApiConsts.paymentMethods}/$paymentId",
      token: ApiConsts.stripeToken,
      headers: {
        "authorization": "Bearer ${ApiConsts.stripeToken}",
      },
    );
    return response;
  }

  getUserOrders() async {
    var response = await api.get(
      "${ApiConsts.apiBaseUrl}${ApiConsts.transaction}${ApiConsts.orders}",
    );
    return response;
  }

  postRatings({
    required List<Map<String, dynamic>> ratings,
    required String orderID,
  }) async {
    var response = await api.post(
      "${ApiConsts.apiBaseUrl}${ApiConsts.ratings}${ApiConsts.addRating}/$orderID",
      data: ratings,
    );
    return response;
  }

  postTransaction({
    required Map<String, dynamic> transaction,
  }) async {
    var response = await api.post(
      "${ApiConsts.apiBaseUrl}${ApiConsts.transaction}${ApiConsts.saveTransactions}",
      data: transaction,
    );
    return response;
  }
}
