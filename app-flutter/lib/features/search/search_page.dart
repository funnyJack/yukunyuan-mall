import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/api_exception.dart';
import '../../data/mock_products.dart';
import '../../data/product_api.dart';
import '../../models/product.dart';
import '../home/product_detail_page.dart';

/// 搜索页：关键字走 `GET /api/products?q=`，分类名走 `category` 参数。
class SearchPage extends StatefulWidget {
  const SearchPage({super.key, required this.productApi});

  final ProductApi productApi;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  String _keyword = '';
  List<Product> _results = const <Product>[];
  bool _loading = false;
  String? _error;
  int _requestId = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onKeywordChanged(String value) {
    setState(() => _keyword = value);
    _debounce?.cancel();
    final String key = value.trim();
    if (key.isEmpty) {
      setState(() {
        _results = const <Product>[];
        _loading = false;
        _error = null;
      });
      return;
    }
    setState(() => _loading = true);
    _debounce = Timer(const Duration(milliseconds: 300), () => _search(key));
  }

  Future<void> _search(String key) async {
    final int requestId = ++_requestId;
    final bool byCategory =
        kCategories.contains(key) && key != kCategories.first;
    try {
      final List<Product> results = await widget.productApi.list(
        category: byCategory ? key : null,
        keyword: byCategory ? null : key,
      );
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _results = results;
        _loading = false;
        _error = null;
      });
    } on ApiException catch (error) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _results = const <Product>[];
        _loading = false;
        _error = error.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: false,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: '搜商品、商家或分类',
            prefixIcon: const Icon(Icons.search, size: 20),
            isDense: true,
            suffixIcon: _keyword.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      _controller.clear();
                      setState(() => _keyword = '');
                    },
                  ),
          ),
          onChanged: _onKeywordChanged,
        ),
      ),
      body: Column(
        children: [
          if (_loading) const LinearProgressIndicator(minHeight: 2),
          Expanded(child: _buildBody(_results)),
        ],
      ),
    );
  }

  Widget _buildBody(List<Product> results) {
    if (_keyword.trim().isEmpty) {
      return const _Hint(
        icon: Icons.travel_explore_outlined,
        text: '输入关键字，看看其他商家在卖什么',
      );
    }
    if (_error != null) {
      return _Hint(icon: Icons.cloud_off_outlined, text: _error!);
    }
    if (_loading && results.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (results.isEmpty) {
      return _Hint(icon: Icons.search_off, text: '没搜到「${_keyword.trim()}」相关商品');
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: results.length,
      separatorBuilder: (context, index) =>
          const Divider(height: 1, indent: 84, endIndent: 16),
      itemBuilder: (context, index) {
        final Product product = results[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 6,
          ),
          leading: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.categoryColor(product.category),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              AppTheme.categoryIcon(product.category),
              color: Colors.black26,
            ),
          ),
          title: Text(
            product.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${product.sellerName} · ${product.category}',
              style: const TextStyle(
                fontSize: 11.5,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          trailing: Text(
            product.priceLabel,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => ProductDetailPage(
                product: product,
                productApi: widget.productApi,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: const Color(0xFFB9B9C0)),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
