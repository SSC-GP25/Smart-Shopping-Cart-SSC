import 'package:smart_cart_app/features/authentication/data/models/login_model.dart';

abstract class AuthStates {}

class AuthInitial extends AuthStates {}

class ChangePasswordVisibility extends AuthStates {}

class ResetVisibility extends AuthStates {}

class ChangeGender extends AuthStates {}

class AuthSignUpLoading extends AuthStates {}

class AuthSignUpFailure extends AuthStates {
  String errMessage;
  AuthSignUpFailure(this.errMessage);
}

class AuthSignUpSuccess extends AuthStates {}

class AuthLoginLoading extends AuthStates {}

class AuthLoginFailure extends AuthStates {
  String errMessage;
  AuthLoginFailure(this.errMessage);
}

class AuthLoginSuccess extends AuthStates {
  LoginModel loginModel;
  AuthLoginSuccess(this.loginModel);
}

class AuthLogoutLoading extends AuthStates {}

class AuthLogoutFailure extends AuthStates {
  String errMessage;

  AuthLogoutFailure(this.errMessage);
}

class AuthLogoutSuccess extends AuthStates {}
