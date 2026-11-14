import '../core/formatters.dart';
import 'review.dart';

/// Model san pham, map tu JSON cua DummyJSON `/products`.
class Product {
  const Product({
    required this.id,
    required this.title,
    required this.price,
    this.description = '',
    this.category = '',
    this.brand,
    this.discountPercentage = 0,
    this.rating = 0,
    this.stock = 0,
    this.thumbnail = '',
    this.images = const [],
    this.tags = const [],
    this.reviews = const [],
  });

  final int id;
  final String title;
  final String description;
  final String category;
  final String? brand;

  /// Gia goc (USD) theo API.
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String thumbnail;
  final List<String> images;
  final List<String> tags;
  final List<Review> reviews;

  // ---- Getter tinh toan (business logic nho nam trong model) ----
  int get originalPriceVnd => usdToVnd(price);
  int get salePriceVnd => usdToVnd(price * (1 - discountPercentage / 100));
  bool get hasDiscount => discountPercentage >= 1;
  bool get inStock => stock > 0;

  /// Danh sach anh de hien thi gallery (fallback ve thumbnail).
  List<String> get gallery => images.isNotEmpty ? images : [thumbnail];

  factory Product.fromJson(Map<String, dynamic> json) {
    List<String> stringList(dynamic value) =>
        (value as List?)?.map((e) => e.toString()).toList() ?? const [];

    return Product(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      brand: json['brand'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      thumbnail: json['thumbnail'] as String? ?? '',
      images: stringList(json['images']),
      tags: stringList(json['tags']),
      reviews: (json['reviews'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(Review.fromJson)
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'brand': brand,
        'price': price,
        'discountPercentage': discountPercentage,
        'rating': rating,
        'stock': stock,
        'thumbnail': thumbnail,
        'images': images,
        'tags': tags,
        'reviews': reviews.map((r) => r.toJson()).toList(),
      };
}

/// Mot trang ket qua co phan trang: `{ products, total, skip, limit }`.
class ProductPage {
  const ProductPage({
    required this.products,
    required this.total,
    required this.skip,
  });

  final List<Product> products;
  final int total;
  final int skip;

  bool get hasMore => skip + products.length < total;

  factory ProductPage.fromJson(Map<String, dynamic> json) {
    final products = (json['products'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList();
    return ProductPage(
      products: products,
      total: (json['total'] as num?)?.toInt() ?? products.length,
      skip: (json['skip'] as num?)?.toInt() ?? 0,
    );
  }
}
