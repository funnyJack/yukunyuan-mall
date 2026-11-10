import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/api_exception.dart';
import '../../data/mock_products.dart';
import '../../data/product_api.dart';
import '../../models/product.dart';
import 'product_detail_page.dart';
import 'widgets/category_strip.dart';
import 'widgets/product_card.dart';
import 'widgets/store_prompt_banner.dart';

/// 商城首页：成员制提示 + 分类筛选 + 商品流。
///
/// 列表来自 `GET /api/products`，下拉刷新时先打 `GET /api/health` 确认后端可达。
class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.productApi,
    required this.onOpenPublish,
    required this.onOpenSearch,
    this.reloadToken = 0,
  });

  final ProductApi productApi;
  final VoidCallback onOpenPublish;
  final VoidCallback onOpenSearch;

  /// 上架成功后由外壳递增，用来刷新当前分类的商品。
  final int reloadToken;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _category = kCategories.first;
  List<Product> _products = const <Product>[];
  bool _loading = true;
  String? _error;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _load(checkHealth: true);
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reloadToken != widget.reloadToken) {
      _load();
    }
  }

  void _selectCategory(String category) {
    if (category == _category) return;
    setState(() {
      _category = category;
      _products = const <Product>[];
      _loading = true;
      _error = null;
    });
    _load();
  }

  Future<void> _load({bool checkHealth = false}) async {
    final int requestId = ++_requestId;
    try {
      if (checkHealth) await widget.productApi.health();
      final List<Product> products = await widget.productApi.list(
        category: _category,
      );
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _products = products;
        _loading = false;
        _error = null;
      });
    } on ApiException catch (error) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _loading = false;
        _error = _products.isEmpty ? error.message : null;
      });
      if (_products.isNotEmpty) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }

  void _openDetail(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) =>
            ProductDetailPage(product: product, productApi: widget.productApi),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _load(checkHealth: true),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              title: const Text('宇坤商城'),
              actions: [
                IconButton(
                  onPressed: widget.onOpenSearch,
                  icon: const Icon(Icons.search),
                  tooltip: '搜索商品',
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: StorePromptBanner(onOpenPublish: widget.onOpenPublish),
            ),
            SliverToBoxAdapter(
              child: CategoryStrip(
                selected: _category,
                onSelected: _selectCategory,
              ),
            ),
            if (_loading && _products.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null && _products.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _ErrorState(
                  message: _error!,
                  onRetry: () => _load(checkHealth: true),
                ),
              )
            else if (_products.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(onOpenPublish: widget.onOpenPublish),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 210,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.66,
                  ),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final Product product = _products[index];
                    return ProductCard(
                      product: product,
                      onTap: () => _openDetail(product),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 56,
            color: Color(0xFFB9B9C0),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 160,
            child: FilledButton(onPressed: onRetry, child: const Text('重试')),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onOpenPublish});

  final VoidCallback onOpenPublish;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: 56,
            color: Color(0xFFB9B9C0),
          ),
          const SizedBox(height: 12),
          const Text(
            '这个分类还没有上架商品',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 160,
            child: FilledButton(
              onPressed: onOpenPublish,
              child: const Text('去上架'),
            ),
          ),
        ],
      ),
    );
  }
}
