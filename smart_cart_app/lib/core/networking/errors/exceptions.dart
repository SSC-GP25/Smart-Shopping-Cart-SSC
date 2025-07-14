import 'package:dio/dio.dart';
import 'package:smart_cart_app/core/networking/errors/error_model.dart';

class ServerException implements Exception {
  final ErrorModel errorModel;

  ServerException({required this.errorModel});
}

//Handling all possible Dio Exceptions
void handleDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
      throw ServerException(
        errorModel: ErrorModel(
          errMessage:
              "Connection timed out. Please check your internet connection and try again.",
        ),
      );
    case DioExceptionType.sendTimeout:
      throw ServerException(
        errorModel: ErrorModel(
          errMessage: "Request timed out while sending data. Please try again.",
        ),
      );
    case DioExceptionType.receiveTimeout:
      throw ServerException(
        errorModel: ErrorModel(
          errMessage:
              "Request timed out while receiving data. Please try again.",
        ),
      );
    case DioExceptionType.badCertificate:
      throw ServerException(
        errorModel: ErrorModel(
          errMessage:
              "Security certificate error. Please ensure you're using a secure connection.",
        ),
      );
    case DioExceptionType.cancel:
      throw ServerException(
        errorModel: ErrorModel(
          errMessage: "Request was cancelled. Please try again.",
        ),
      );
    case DioExceptionType.connectionError:
      throw ServerException(
        errorModel: ErrorModel(
          errMessage:
              "Unable to connect to the server. Please check your internet connection.",
        ),
      );
    case DioExceptionType.unknown:
      throw ServerException(
        errorModel: ErrorModel(
          errMessage: "An unexpected error occurred. Please try again later.",
        ),
      );
    case DioExceptionType.badResponse:
      switch (e.response?.statusCode) {
        case 400:
          throw ServerException(
            errorModel: ErrorModel.fromJson(e.response!.data),
          );
        case 401:
          throw ServerException(
            errorModel: ErrorModel.fromJson(e.response!.data),
          );
        case 403:
          throw ServerException(
            errorModel: ErrorModel.fromJson(e.response!.data),
          );
        case 404:
          throw ServerException(
            errorModel: ErrorModel.fromJson(e.response!.data),
          );
        case 409:
          throw ServerException(
            errorModel: ErrorModel.fromJson(e.response!.data),
          );
        case 422:
          throw ServerException(
            errorModel: ErrorModel.fromJson(e.response!.data),
          );
        case 500:
          throw ServerException(
            errorModel: ErrorModel(
              errMessage: "Internal server error. Please try again later.",
            ),
          );
        case 502:
          throw ServerException(
            errorModel: ErrorModel(
              errMessage: "Bad gateway. Please try again later.",
            ),
          );
        case 503:
          throw ServerException(
            errorModel: ErrorModel(
              errMessage: "Service unavailable. Please try again later.",
            ),
          );
        case 504:
          throw ServerException(
            errorModel: ErrorModel(
              errMessage: "Gateway timeout. Please try again later.",
            ),
          );
        default:
          throw ServerException(
            errorModel: ErrorModel(
              errMessage:
                  "An unexpected error occurred. Please try again later.",
            ),
          );
      }
  }
}
