import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../models/product.dart';
import 'api_exception.dart';

/// 商品相关接口。页面只依赖这一层，测试可以换成本地实现。
abstract class ProductApi {
  /// GET /api/health
  Future<void> health();

  /// GET /api/products?category=&q=
  ///
  /// [category] 传「全部」、空串或 null 时不筛选。
  Future<List<Product>> list({String? category, String? keyword});

  /// GET /api/products/{id}
  Future<Product> detail(String id);

  /// POST /api/products
  Future<Product> create(ProductDraft draft);
}

class HttpProductApi implements ProductApi {
  HttpProductApi({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? resolveApiBaseUrl();

  final http.Client _client;
  final String _baseUrl;

  static const Duration _timeout = Duration(seconds: 10);

  @override
  Future<void> health() async {
    final Map<String, dynamic> body = _decodeObject(
      await _send(
        () => _client.get(
          Uri.parse('$_baseUrl/api/health'),
          headers: _jsonHeaders,
        ),
      ),
    );
    if (body['status'] != 'ok') {
      throw const ApiException('后端状态异常');
    }
  }

  @override
  Future<List<Product>> list({String? category, String? keyword}) async {
    final String categoryValue = (category ?? '').trim();
    final String keywordValue = (keyword ?? '').trim();
    final Map<String, String> query = <String, String>{
      if (categoryValue.isNotEmpty && categoryValue != '全部')
        'category': categoryValue,
      if (keywordValue.isNotEmpty) 'q': keywordValue,
    };
    final http.Response response = await _send(
      () => _client.get(
        Uri.parse('$_baseUrl/api/products').replace(queryParameters: query),
        headers: _jsonHeaders,
      ),
    );
    final dynamic data = _decode(response);
    if (data is! List) {
      throw const ApiException('商品列表格式不正确');
    }
    return data
        .map((dynamic item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Product> detail(String id) async {
    final http.Response response = await _send(
      () => _client.get(
        Uri.parse('$_baseUrl/api/products/${Uri.encodeComponent(id)}'),
        headers: _jsonHeaders,
      ),
    );
    return Product.fromJson(_decodeObject(response));
  }

  @override
  Future<Product> create(ProductDraft draft) async {
    final http.Response response = await _send(
      () => _client.post(
        Uri.parse('$_baseUrl/api/products'),
        headers: _jsonHeaders,
        body: jsonEncode(draft.toJson()),
      ),
    );
    return Product.fromJson(_decodeObject(response));
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      final http.Response response = await request().timeout(_timeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      }
      throw _errorFrom(response);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException('连接后端超时，请确认 mall-backend 已在 8080 端口启动');
    } on http.ClientException catch (error) {
      throw ApiException('无法连接后端：${error.message}');
    }
  }

  Map<String, String> get _jsonHeaders => const <String, String>{
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  Map<String, dynamic> _decodeObject(http.Response response) {
    final dynamic data = _decode(response);
    if (data is! Map<String, dynamic>) {
      throw const ApiException('后端返回的数据格式不正确');
    }
    return data;
  }

  dynamic _decode(http.Response response) {
    if (response.body.isEmpty) {
      throw const ApiException('后端返回了空响应');
    }
    try {
      return jsonDecode(response.body);
    } on FormatException {
      throw const ApiException('后端返回的数据不是 JSON');
    }
  }

  ApiException _errorFrom(http.Response response) {
    try {
      final dynamic data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        final Object? rawFields = data['fieldErrors'];
        final Map<String, String> fieldErrors = rawFields is Map
            ? rawFields.map(
                (dynamic key, dynamic value) =>
                    MapEntry(key.toString(), value.toString()),
              )
            : const <String, String>{};
        final String? message = data['message'] as String?;
        return ApiException(
          message ?? '请求失败（${response.statusCode}）',
          statusCode: response.statusCode,
          code: data['code'] as String? ?? 'HTTP_${response.statusCode}',
          fieldErrors: fieldErrors,
        );
      }
    } on FormatException {
      // 落到下面的通用错误。
    }
    return ApiException(
      '请求失败（${response.statusCode}）',
      statusCode: response.statusCode,
      code: 'HTTP_${response.statusCode}',
    );
  }
}
