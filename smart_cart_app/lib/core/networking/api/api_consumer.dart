abstract class ApiConsumer {
  Future<dynamic> get(
    String path, {
    String? token,
    Object? data,
    String? contentType,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });
  Future<dynamic> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    String? token,
    String? contentType,
    Map<String, String>? headers,
  });
  Future<dynamic> patch(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  });
  Future<dynamic> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  });
}
