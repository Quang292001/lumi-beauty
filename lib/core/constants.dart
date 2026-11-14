/// Cac hang so dung chung trong app.
class ApiConstants {
  ApiConstants._();

  /// REST API cong khai: https://dummyjson.com/docs
  static const String baseUrl = 'https://dummyjson.com';
  static const Duration timeout = Duration(seconds: 15);

  /// Token song 1 ngay (DummyJSON mac dinh la 60 phut).
  static const int tokenExpiresInMins = 1440;
}

/// Ty gia quy doi tu USD (gia goc cua API) sang VND de hien thi.
const int kUsdToVnd = 25000;

/// Don hang tu muc nay tro len duoc mien phi van chuyen.
const int kFreeShippingThreshold = 500000;
const int kShippingFee = 30000;

/// Danh muc san pham hien thi tren trang chu (slug theo API).
class AppCategory {
  const AppCategory(this.slug, this.label);

  final String slug;
  final String label;
}

const List<AppCategory> kCategories = [
  AppCategory('beauty', 'Trang điểm'),
  AppCategory('skin-care', 'Chăm sóc da'),
  AppCategory('fragrances', 'Nước hoa'),
];

/// Tap slug cua cac danh muc lam dep, dung de loc ket qua tim kiem.
final Set<String> kBeautySlugs = kCategories.map((c) => c.slug).toSet();
