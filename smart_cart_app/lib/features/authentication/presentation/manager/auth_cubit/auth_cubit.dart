import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_cart_app/core/services/cache_helper.dart';
import 'package:smart_cart_app/core/services/secure_storage.dart';
import 'package:smart_cart_app/features/authentication/data/models/login_model.dart';
import 'package:smart_cart_app/features/authentication/data/repos/auth_repo.dart';

import 'auth_states.dart';

class AuthCubit extends Cubit<AuthStates> {
  AuthCubit(this.authRepo) : super(AuthInitial());

  static AuthCubit get(context) => BlocProvider.of(context);
  AuthRepo authRepo;
  Icon passwordIcon = const Icon(Icons.visibility_outlined);
  bool isPassword = true;
  Icon confirmedPasswordIcon = const Icon(Icons.visibility_outlined);
  bool isConfirmedPassword = true;
  bool isMaleSelected = true;
  String gender = "Male";
  String verificationCode = "";
  LoginModel? loginModel;

  void resetVisibility() {
    isPassword = true;
    passwordIcon = const Icon(Icons.visibility_outlined);
    emit(ResetVisibility());
  }

  void changePasswordVisibility() {
    isPassword = !isPassword;
    passwordIcon = isPassword
        ? const Icon(Icons.visibility_outlined)
        : const Icon(Icons.visibility_off_outlined);
    emit(ChangePasswordVisibility());
  }

  void changeConfirmedPasswordVisibility() {
    isConfirmedPassword = !isConfirmedPassword;
    confirmedPasswordIcon = isConfirmedPassword
        ? const Icon(Icons.visibility_outlined)
        : const Icon(Icons.visibility_off_outlined);
    emit(ChangePasswordVisibility());
  }

  void changeGender(bool isMale) {
    isMaleSelected = isMale;
    gender = isMale ? "Male" : "Female";
    emit(ChangeGender());
  }

  Future<void> signupUser({
    required String name,
    required String email,
    required String password,
    required String gender,
    required String birthdate,
  }) async {
    emit(AuthSignUpLoading());
    var result = await authRepo.signUpUser(
        name: name,
        email: email,
        password: password,
        gender: gender,
        birthdate: birthdate);
    result.fold((failure) {
      emit(AuthSignUpFailure(failure));
    }, (success) {
      emit(AuthSignUpSuccess());
    });
  }

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    emit(AuthLoginLoading());
    var result = await authRepo.loginUser(
      email: email,
      password: password,
    );
    result.fold((failure) {
      emit(AuthLoginFailure(failure));
    }, (loginModel) {
      CacheHelper.putString(
          key: CacheHelperKeys.token, value: loginModel.accessToken!);
      CacheHelper.putString(
          key: CacheHelperKeys.stripeCustomerId,
          value: loginModel.stripeCustomerId!);
      SecureStorage().writeData(
          key: SecureStorageKeys.refreshToken, value: loginModel.refreshToken!);
      CacheHelper.putString(key: CacheHelperKeys.userID, value: loginModel.id!);
      this.loginModel = loginModel;
      emit(AuthLoginSuccess(loginModel));
    });
  }

  void logoutUser() {
    CacheHelper.remove(key: CacheHelperKeys.token);
    CacheHelper.remove(key: CacheHelperKeys.cartID);
    CacheHelper.remove(key: CacheHelperKeys.stripeCustomerId);
    CacheHelper.remove(key: CacheHelperKeys.userID);
    SecureStorage().deleteData(key: SecureStorageKeys.refreshToken);
    emit(AuthLogoutSuccess());
  }
}
