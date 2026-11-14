import 'package:lumi_beauty/data/cart_repository.dart';
import 'package:lumi_beauty/models/cart_item.dart';
import 'package:lumi_beauty/models/product.dart';

/// Repository gia luu trong bo nho -> test khong can SQLite that.
class FakeCartRepository implements CartRepository {
  final Map<int, CartItem> store = {};

  @override
  Future<List<CartItem>> getAll() async => store.values.toList();

  @override
  Future<void> upsert(CartItem item) async => store[item.productId] = item;

  @override
  Future<void> remove(int productId) async => store.remove(productId);

  @override
  Future<void> clear() async => store.clear();
}

Product fakeProduct({
  int id = 1,
  double price = 10,
  double discount = 0,
  int stock = 5,
}) {
  return Product(
    id: id,
    title: 'Product $id',
    price: price,
    discountPercentage: discount,
    stock: stock,
    category: 'beauty',
  );
}
