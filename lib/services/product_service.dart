import '../core/api_client.dart';
import '../core/constants.dart';
import '../models/product.dart';

/// Goi cac endpoint san pham cua DummyJSON.
class ProductService {
  ProductService(this._api);

  final ApiClient _api;

  /// GET /products/category/{slug}?limit=&skip=
  Future<ProductPage> getByCategory(
    String slug, {
    int skip = 0,
    int limit = 10,
  }) async {
    final json = await _api.get(
      '/products/category/$slug',
      query: {'skip': '$skip', 'limit': '$limit'},
    );
    return ProductPage.fromJson(json as Map<String, dynamic>);
  }

  /// GET /products/{id}
  Future<Product> getById(int id) async {
    final json = await _api.get('/products/$id');
    return Product.fromJson(json as Map<String, dynamic>);
  }

  /// GET /products/search?q=
  /// API tim tren toan bo catalogue (ca dien thoai, laptop...), nen lay het
  /// ket qua (`limit=0`) roi chi giu lai san pham thuoc nhom lam dep.
  Future<List<Product>> searchBeauty(String query) async {
    final json = await _api.get(
      '/products/search',
      query: {'q': query, 'limit': '0'},
    );
    final page = ProductPage.fromJson(json as Map<String, dynamic>);
    return page.products.where((p) => kBeautySlugs.contains(p.category)).toList();
  }
}
