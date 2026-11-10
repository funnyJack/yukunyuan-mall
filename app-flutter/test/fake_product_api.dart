import 'package:yukunyuan_mall/data/api_exception.dart';
import 'package:yukunyuan_mall/data/mock_products.dart';
import 'package:yukunyuan_mall/data/product_api.dart';
import 'package:yukunyuan_mall/models/product.dart';

/// 测试用商品接口，筛选规则与后端 `ProductRepository.search` 一致。
class FakeProductApi implements ProductApi {
  FakeProductApi({List<Product>? products})
    : _products = List<Product>.of(products ?? kMockProducts);

  final List<Product> _products;

  @override
  Future<void> health() async {}

  @override
  Future<List<Product>> list({String? category, String? keyword}) async {
    final String categoryValue = (category ?? '').trim();
    final String keywordValue = (keyword ?? '').trim();
    return _products.where((Product product) {
      if (categoryValue.isNotEmpty &&
          categoryValue != '全部' &&
          product.category != categoryValue) {
        return false;
      }
      if (keywordValue.isEmpty) return true;
      return product.title.contains(keywordValue) ||
          product.description.contains(keywordValue) ||
          product.sellerName.contains(keywordValue);
    }).toList();
  }

  @override
  Future<Product> detail(String id) async {
    for (final Product product in _products) {
      if (product.id == id) return product;
    }
    throw ApiException('商品不存在：$id', statusCode: 404, code: 'PRODUCT_NOT_FOUND');
  }

  @override
  Future<Product> create(ProductDraft draft) async {
    final Product product = Product(
      id: 'new-${_products.length + 1}',
      title: draft.title,
      description: draft.description,
      priceCents: draft.priceCents,
      category: draft.category,
      sellerName: draft.sellerName.isEmpty ? '匿名店主' : draft.sellerName,
      stock: draft.stock,
    );
    _products.insert(0, product);
    return product;
  }
}
