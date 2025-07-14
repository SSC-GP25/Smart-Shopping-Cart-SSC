import 'package:dio/dio.dart';
import 'package:smart_cart_app/core/networking/api/api_consumer.dart';
import 'package:smart_cart_app/core/networking/errors/exceptions.dart';
import 'package:smart_cart_app/core/services/cache_helper.dart';
import 'package:smart_cart_app/core/services/helper_functions.dart';
import 'package:smart_cart_app/core/services/secure_storage.dart';

import 'api_consts.dart';

class DioConsumer extends ApiConsumer {
  final Dio dio;

  DioConsumer({required this.dio}) {
    dio.interceptors.add(LogInterceptor(
      responseBody: true,
      requestHeader: true,
    ));
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 &&
              error.response!.data["message"] == "invalid refresh token") {
            final newToken = await refreshToken();
            if (newToken != null) {
              dio.options.headers["authorization"] = "Bearer $newToken";
              return handler
                  .resolve(await dio.request(error.requestOptions.path));
            }
            return handler.next(error);
          }
          if (error.response?.statusCode == 403) {
            showSessionExpiredQuickAlert();
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<String?> refreshToken() async {
    try {
      final refreshToken =
          await SecureStorage().readData(key: SecureStorageKeys.refreshToken);

      var response = await dio.post(
        '${ApiConsts.apiBaseUrl}${ApiConsts.auth}${ApiConsts.refreshToken}',
        data: {"refreshToken": refreshToken},
      );
      final newToken = response.data["accessToken"];
      CacheHelper.putString(key: CacheHelperKeys.token, value: newToken);
      return newToken;
    } catch (e) {
      CacheHelper.remove(key: CacheHelperKeys.token);
    }
    return null;
  }

  @override
  Future get(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    String? token,
    String? contentType,
    Map<String, String>? headers,
  }) async {
    try {
      final userToken = CacheHelper.getString(key: CacheHelperKeys.token);
      // dio.options.headers["authorization"] = "Bearer $token";
      final response = await dio.get(
        path,
        data: data,
        options: Options(
            contentType: contentType,
            headers: headers ?? {"authorization": "Bearer $userToken"}),
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future patch(String path,
      {Object? data, Map<String, dynamic>? queryParameters}) async {
    try {
      final token = CacheHelper.getString(key: CacheHelperKeys.token);
      dio.options.headers["authorization"] = "Bearer $token";
      final response = await dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    String? token,
    String? contentType,
    Map<String, String>? headers,
  }) async {
    try {
      final userToken = CacheHelper.getString(key: CacheHelperKeys.token);
      // Remember to add the token for each method use this
      final response = await dio.post(
        path,
        data: data,
        options: Options(
            contentType: contentType,
            headers: headers ?? {"authorization": "Bearer $userToken"}),
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future delete(String path,
      {Object? data, Map<String, dynamic>? queryParameters}) async {
    try {
      final token = CacheHelper.getString(key: CacheHelperKeys.token);
      dio.options.headers["authorization"] = "Bearer $token";
      final response = await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response.statusCode;
    } on DioException catch (e) {
      handleDioException(e);
    }
  }
}
