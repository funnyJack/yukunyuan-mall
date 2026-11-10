import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yukunyuan_mall/data/api_exception.dart';
import 'package:yukunyuan_mall/data/product_api.dart';
import 'package:yukunyuan_mall/models/product.dart';

/// 真实后端冒烟测试（默认跳过，不联网、不写库）。
///
/// 先启动后端，再跑：
///
/// ```powershell
/// $env:LIVE_API = '1'
/// flutter test test/live_api_smoke_test.dart
/// ```
///
/// 会往开发库里写一条「冒烟测试商品」，用来验证 POST /api/products 的完整链路。
void main() {
  final bool live = Platform.environment['LIVE_API'] == '1';

  test(
    '真实后端：健康检查 → 列表 → 详情 → 上架 → 再查列表',
    () async {
      final HttpProductApi api = HttpProductApi(baseUrl: 'http://localhost:8080');

      await api.health();

      final List<Product> before = await api.list();
      expect(before, isNotEmpty, reason: '后端应已 seed 演示商品');

      final Product first = before.first;
      final Product detail = await api.detail(first.id);
      expect(detail.title, first.title);

      final String title =
          '冒烟测试商品 ${DateTime.now().millisecondsSinceEpoch % 100000}';
      final Product created = await api.create(
        ProductDraft(
          title: title,
          priceCents: 1234,
          category: '手作',
          description: '由 live_api_smoke_test 创建，可忽略',
          sellerName: '宇坤的小店',
          stock: 1,
        ),
      );
      expect(created.title, title);
      expect(created.priceCents, 1234);
      expect(created.category, '手作');
      expect(created.id, isNotEmpty);

      final Product createdDetail = await api.detail(created.id);
      expect(createdDetail.title, title);

      final List<Product> after = await api.list();
      expect(after.length, before.length + 1);

      final List<Product> handmade = await api.list(category: '手作');
      expect(
        handmade.any((Product product) => product.id == created.id),
        isTrue,
        reason: '按分类筛选应能查到刚上架的商品',
      );

      await expectLater(
        api.detail('not-exist-id'),
        throwsA(isA<ApiException>()),
      );
    },
    skip: live ? false : '需要后端在 localhost:8080 运行；设置 LIVE_API=1 才执行',
  );
}
