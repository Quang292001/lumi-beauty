import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_beauty/models/product.dart';

void main() {
  // Rut gon tu response that cua GET https://dummyjson.com/products/1
  final json = <String, dynamic>{
    'id': 1,
    'title': 'Essence Mascara Lash Princess',
    'description': 'Popular mascara',
    'category': 'beauty',
    'price': 9.99,
    'discountPercentage': 10.48,
    'rating': 2.56,
    'stock': 99,
    'tags': ['beauty', 'mascara'],
    'brand': 'Essence',
    'reviews': [
      {
        'rating': 3,
        'comment': 'Would not recommend!',
        'date': '2025-04-30T09:41:02.053Z',
        'reviewerName': 'Eleanor Collins',
      },
    ],
    'images': ['https://cdn.dummyjson.com/a.webp'],
    'thumbnail': 'https://cdn.dummyjson.com/thumb.webp',
  };

  group('Product.fromJson', () {
    test('parse day du cac truong', () {
      final p = Product.fromJson(json);
      expect(p.id, 1);
      expect(p.brand, 'Essence');
      expect(p.tags, ['beauty', 'mascara']);
      expect(p.reviews.single.reviewerName, 'Eleanor Collins');
      expect(p.reviews.single.date?.year, 2025);
    });

    test('tinh gia VND va giam gia', () {
      final p = Product.fromJson(json);
      expect(p.originalPriceVnd, 250000);
      expect(p.salePriceVnd, 224000); // 9.99 * 0.8952 * 25000 = 223.578 -> 224.000
      expect(p.hasDiscount, isTrue);
      expect(p.inStock, isTrue);
    });

    test('thieu truong khong bi crash (brand null, khong co reviews)', () {
      final p = Product.fromJson({'id': 2, 'title': 'X', 'price': 5});
      expect(p.brand, isNull);
      expect(p.reviews, isEmpty);
      expect(p.gallery, ['']);
    });

    test('toJson -> fromJson giu nguyen du lieu', () {
      final p = Product.fromJson(Product.fromJson(json).toJson());
      expect(p.title, json['title']);
      expect(p.price, 9.99);
      expect(p.reviews.length, 1);
    });
  });

  test('ProductPage.hasMore', () {
    final page = ProductPage.fromJson({
      'products': [json],
      'total': 5,
      'skip': 0,
      'limit': 1,
    });
    expect(page.hasMore, isTrue);
    expect(ProductPage(products: page.products, total: 5, skip: 4).hasMore, isFalse);
  });
}
