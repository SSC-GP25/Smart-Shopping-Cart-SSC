import 'package:either_dart/either.dart';

import '../models/login_model.dart';

abstract class AuthRepo {
  Future<Either<String, Map<String, dynamic>>> signUpUser({
    required String name,
    required String email,
    required String password,
    required String gender,
    required String birthdate,
  });
  Future<Either<String, Map<String, dynamic>>> verifyEmail(
      {required String code});
  Future<Either<String, LoginModel>> loginUser({
    required String email,
    required String password,
  });
}
