import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:yukunyuan_mall/data/api_exception.dart';
import 'package:yukunyuan_mall/data/product_api.dart';
import 'package:yukunyuan_mall/models/product.dart';

void main() {
  const String baseUrl = 'http://localhost:8080';

  http.Response jsonResponse(Object body, int statusCode) {
    return http.Response.bytes(
      utf8.encode(jsonEncode(body)),
      statusCode,
      headers: const <String, String>{
        'content-type': 'application/json; charset=utf-8',
      },
    );
  }

  Map<String, dynamic> soap() => <String, dynamic>{
    'id': 'p1',
    'title': '手工皂礼盒（三块装）',
    'description': '冷制皂',
    'priceCents': 6800,
    'category': '手作',
    'sellerName': '阿梅的小铺',
    'stock': 12,
  };

  test('列表、详情、健康检查和上架都打到对应路径', () async {
    late http.Request created;
    final HttpProductApi api = HttpProductApi(
      baseUrl: baseUrl,
      client: MockClient((http.Request request) async {
        if (request.url.path == '/api/health') {
          return http.Response(
            jsonEncode(<String, String>{
              'status': 'ok',
              'service': 'mall-backend',
            }),
            200,
          );
        }
        if (request.method == 'GET' && request.url.path == '/api/products') {
          expect(request.url.queryParameters['category'], '食品');
          expect(request.url.queryParameters['q'], '相机');
          return jsonResponse(<Map<String, dynamic>>[soap()], 200);
        }
        if (request.method == 'GET' && request.url.path == '/api/products/p1') {
          return jsonResponse(soap(), 200);
        }
        if (request.method == 'POST' && request.url.path == '/api/products') {
          created = request;
          return jsonResponse(<String, dynamic>{
            ...soap(),
            'id': 'new-id',
            'title': '新手作',
            'priceCents': 6800,
            'stock': 1,
          }, 201);
        }
        return http.Response('not found', 404);
      }),
    );

    await api.health();

    final List<Product> products = await api.list(
      category: '食品',
      keyword: '相机',
    );
    expect(products, hasLength(1));
    expect(products.single.title, '手工皂礼盒（三块装）');
    expect(products.single.priceCents, 6800);

    final Product detail = await api.detail('p1');
    expect(detail.sellerName, '阿梅的小铺');

    final Product createdProduct = await api.create(
      const ProductDraft(
        title: '新手作',
        priceCents: 6800,
        category: '手作',
        description: '冷制皂',
        sellerName: '宇坤的小店',
      ),
    );
    expect(createdProduct.id, 'new-id');
    expect(created.headers['content-type'], contains('application/json'));
    expect(jsonDecode(created.body), <String, dynamic>{
      'title': '新手作',
      'priceCents': 6800,
      'category': '手作',
      'description': '冷制皂',
      'sellerName': '宇坤的小店',
      'stock': 1,
    });
  });

  test('校验失败时带上后端返回的字段错误', () async {
    final HttpProductApi api = HttpProductApi(
      baseUrl: baseUrl,
      client: MockClient((http.Request request) async {
        return jsonResponse(<String, dynamic>{
          'code': 'VALIDATION_FAILED',
          'message': '商品名称不能为空',
          'fieldErrors': <String, String>{'title': '商品名称不能为空'},
        }, 400);
      }),
    );

    expect(
      () => api.create(
        const ProductDraft(title: '', priceCents: 100, category: '手作'),
      ),
      throwsA(
        isA<ApiException>()
            .having(
              (ApiException error) => error.code,
              'code',
              'VALIDATION_FAILED',
            )
            .having(
              (ApiException error) => error.fieldErrors['title'],
              'title',
              '商品名称不能为空',
            ),
      ),
    );
  });

  test('商品不存在时抛出 404', () async {
    final HttpProductApi api = HttpProductApi(
      baseUrl: baseUrl,
      client: MockClient((http.Request request) async {
        return jsonResponse(<String, String>{
          'code': 'PRODUCT_NOT_FOUND',
          'message': '商品不存在：missing',
        }, 404);
      }),
    );

    expect(
      () => api.detail('missing'),
      throwsA(
        isA<ApiException>().having(
          (ApiException error) => error.statusCode,
          'statusCode',
          404,
        ),
      ),
    );
  });
}
