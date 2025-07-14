import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static SharedPreferences? sharedPreferences;

  static init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  static Future<bool> putBoolean(
      {required String key, required bool value}) async {
    return await sharedPreferences!.setBool(key, value);
  }

  static bool? getBoolean({required String key}) {
    return sharedPreferences!.getBool(key);
  }

  static Future<bool> putString(
      {required String key, required String value}) async {
    return await sharedPreferences!.setString(key, value);
  }

  static String? getString({required String key}) {
    return sharedPreferences?.getString(key);
  }

  static void remove({required String key}) {
    sharedPreferences!.remove(key);
  }
}

class CacheHelperKeys {
  static const String cartID = "cartID";
  static const String userID = "userID";
  static const String token = "token";
  static const String stripeCustomerId = "stripeCustomerId";
  static const String stripeSessionId = "stripeSessionId";
  static const String onBoarding = "onBoarding";
}
