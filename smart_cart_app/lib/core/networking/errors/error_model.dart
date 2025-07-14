import 'package:smart_cart_app/core/networking/api/api_consts.dart';

class ErrorModel {
  // final int statusCode;
  final String errMessage;

  ErrorModel({required this.errMessage});
  factory ErrorModel.fromJson(Map<String, dynamic> jsonData) {
    return ErrorModel(
      // statusCode: jsonData["status"],
      errMessage: jsonData[ApiKeys.message] ?? "Something went wrong",
    );
  }
}
