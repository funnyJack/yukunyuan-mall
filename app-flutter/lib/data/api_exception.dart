/// 调用商城后端失败时抛出，[message] 可以直接展示给用户。
class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.statusCode,
    this.code = 'NETWORK',
    this.fieldErrors = const <String, String>{},
  });

  final String message;
  final int? statusCode;
  final String code;
  final Map<String, String> fieldErrors;

  @override
  String toString() => message;
}
