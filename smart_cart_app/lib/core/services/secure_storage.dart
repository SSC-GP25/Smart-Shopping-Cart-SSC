import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  writeData({required String key, required String value}) async {
    await storage.write(key: key, value: value);
  }

  readData({required String key}) async {
    String value = await storage.read(key: key) ?? "";
    return value;
  }

  deleteData({required String key}) async {
    await storage.delete(key: key);
  }
}

class SecureStorageKeys {
  static const refreshToken = "refreshToken";
}
