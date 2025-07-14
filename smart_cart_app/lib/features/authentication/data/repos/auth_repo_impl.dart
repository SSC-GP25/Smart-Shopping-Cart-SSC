import 'package:either_dart/either.dart';
import 'package:smart_cart_app/core/networking/api/api_service.dart';
import 'package:smart_cart_app/core/networking/errors/exceptions.dart';
import 'package:smart_cart_app/features/authentication/data/models/login_model.dart';
import 'package:smart_cart_app/features/authentication/data/repos/auth_repo.dart';

class AuthRepoImpl extends AuthRepo {
  ApiService apiService;
  AuthRepoImpl(this.apiService);
  @override
  Future<Either<String, Map<String, dynamic>>> signUpUser(
      {required String name,
      required String email,
      required String password,
      required String gender,
      required String birthdate}) async {
    try {
      var response = await apiService.signUp(
          name: name,
          email: email,
          password: password,
          gender: gender,
          birthdate: birthdate);
      return Right(response);
    } on ServerException catch (e) {
      return Left(e.errorModel.errMessage);
    }
  }

  @override
  Future<Either<String, Map<String, dynamic>>> verifyEmail(
      {required String code}) async {
    try {
      var response = await apiService.verifyEmail(code: code);
      return Right(response);
    } on ServerException catch (e) {
      return Left(e.errorModel.errMessage);
    }
  }

  @override
  Future<Either<String, LoginModel>> loginUser(
      {required String email, required String password}) async {
    try {
      var response = await apiService.logIn(
        email: email,
        password: password,
      );
      LoginModel loginModel = LoginModel.fromJson(response);
      return Right(loginModel);
    } on ServerException catch (e) {
      return Left(e.errorModel.errMessage);
    }
  }
}
