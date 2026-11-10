import '../core/utils/price.dart';

/// 商品模型。
///
/// 约定：
/// - 金额用 [priceCents]（单位：分）存整数，展示时用 [priceLabel]
/// - [category] 取值见 `kCategories`（data/mock_products.dart）
class Product {
  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.priceCents,
    required this.category,
    required this.sellerName,
    required this.stock,
  });

  /// 后端返回商品 JSON 时用它转换，字段名与后端约定保持一致。
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      title: json['title'] as String,
      description: (json['description'] as String?) ?? '',
      priceCents: (json['priceCents'] as num).toInt(),
      category: (json['category'] as String?) ?? '其他',
      sellerName: json['sellerName'] as String,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
    );
  }

  final String id;
  final String title;
  final String description;
  final int priceCents;
  final String category;
  final String sellerName;
  final int stock;

  bool get isSoldOut => stock <= 0;

  String get priceLabel => formatPrice(priceCents);

  String get sellerInitial =>
      sellerName.isEmpty ? '?' : sellerName.substring(0, 1);
}

/// 上架请求，字段与后端 `CreateProductRequest` 对齐。
class ProductDraft {
  const ProductDraft({
    required this.title,
    required this.priceCents,
    required this.category,
    this.description = '',
    this.sellerName = '',
    this.stock = 1,
  });

  final String title;
  final int priceCents;
  final String category;
  final String description;
  final String sellerName;
  final int stock;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'title': title,
    'priceCents': priceCents,
    'category': category,
    'description': description,
    'sellerName': sellerName,
    'stock': stock,
  };
}
