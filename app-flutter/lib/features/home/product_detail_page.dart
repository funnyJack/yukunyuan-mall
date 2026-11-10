import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/api_exception.dart';
import '../../data/product_api.dart';
import '../../models/product.dart';

/// 商品详情页（最小版）：展示信息 + 「立即购买」占位。
///
/// 进入页面后会再请求 `GET /api/products/{id}`，用最新库存覆盖列表里的快照。
/// 下单、地址、支付都还没接，点击只给一个提示。
class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({
    super.key,
    required this.product,
    required this.productApi,
  });

  final Product product;
  final ProductApi productApi;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Product _product = widget.product;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    try {
      final Product latest = await widget.productApi.detail(widget.product.id);
      if (!mounted) return;
      setState(() => _product = latest);
    } on ApiException {
      // 列表里已经有一份数据，详情失败时继续展示。
    }
  }

  @override
  Widget build(BuildContext context) {
    final Product product = _product;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('商品详情')),
      body: ListView(
        children: [
          AspectRatio(
            aspectRatio: 1.25,
            child: ColoredBox(
              color: AppTheme.categoryColor(product.category),
              child: Center(
                child: Icon(
                  AppTheme.categoryIcon(product.category),
                  size: 72,
                  color: Colors.black26,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  product.priceLabel,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: AppTheme.categoryColor(product.category),
                      child: Text(
                        product.sellerInitial,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      product.sellerName,
                      style: const TextStyle(fontSize: 13),
                    ),
                    const Spacer(),
                    Text(
                      product.isSoldOut ? '已售罄' : '库存 ${product.stock}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 28),
                const Text(
                  '商品描述',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  product.description,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: Color(0xFF5A5A60),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '成员制规则：每位成员需要先上架商品，才能购买其他成员的商品。',
                    style: TextStyle(fontSize: 12, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton(
            onPressed: product.isSoldOut
                ? null
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('下单流程还没接后端，这一步先占个位')),
                    );
                  },
            child: Text(product.isSoldOut ? '已售罄' : '立即购买'),
          ),
        ),
      ),
    );
  }
}
