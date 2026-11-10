import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yukunyuan_mall/app.dart';

import 'fake_product_api.dart';

void main() {
  testWidgets('首页展示商城标题、成员制提示和商品卡片', (tester) async {
    await tester.pumpWidget(MallApp(productApi: FakeProductApi()));
    await tester.pumpAndSettle();

    expect(find.text('宇坤商城'), findsWidgets);
    expect(find.text('成员制商城：先开店，才能买'), findsOneWidget);
    expect(find.text('手工皂礼盒（三块装）'), findsOneWidget);
    expect(find.text('¥68.00'), findsOneWidget);
    expect(find.text('阿梅的小铺'), findsWidgets);
  });

  testWidgets('切换分类后只剩该分类商品', (tester) async {
    await tester.pumpWidget(MallApp(productApi: FakeProductApi()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('数码').first);
    await tester.pumpAndSettle();

    expect(find.text('二手富士 X100V 相机'), findsOneWidget);
    expect(find.text('手工皂礼盒（三块装）'), findsNothing);
  });

  testWidgets('底部导航可以切到上架页并校验表单', (tester) async {
    await tester.pumpWidget(MallApp(productApi: FakeProductApi()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add_box_outlined));
    await tester.pumpAndSettle();

    expect(find.text('上架商品'), findsOneWidget);

    await tester.ensureVisible(find.text('提交上架'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('提交上架'));
    await tester.pumpAndSettle();

    expect(find.text('请填写商品名称'), findsOneWidget);
  });

  testWidgets('点击商品卡片进入详情页', (tester) async {
    await tester.pumpWidget(MallApp(productApi: FakeProductApi()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('手工皂礼盒（三块装）'));
    await tester.pumpAndSettle();

    expect(find.text('商品详情'), findsOneWidget);
    expect(find.text('立即购买'), findsOneWidget);
  });
}
