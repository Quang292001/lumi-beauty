import 'dart:math';

import 'package:flutter/foundation.dart';

import '../core/constants.dart';
import '../data/cart_repository.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  CartProvider(this._repository);

  final CartRepository _repository;

  /// key = productId -> tra cuu O(1).
  final Map<int, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();
  bool get isEmpty => _items.isEmpty;

  /// Tong so luong san pham (hien tren badge).
  int get totalQuantity => _items.values.fold(0, (sum, i) => sum + i.quantity);

  int get subtotalVnd => _items.values.fold(0, (sum, i) => sum + i.totalVnd);

  int get shippingFeeVnd {
    if (isEmpty || subtotalVnd >= kFreeShippingThreshold) return 0;
    return kShippingFee;
  }

  int get grandTotalVnd => subtotalVnd + shippingFeeVnd;

  int quantityOf(int productId) => _items[productId]?.quantity ?? 0;

  Future<void> load() async {
    final saved = await _repository.getAll();
    _items
      ..clear()
      ..addEntries(saved.map((i) => MapEntry(i.productId, i)));
    notifyListeners();
  }

  /// Them san pham. So luong khong vuot qua ton kho.
  Future<void> add(Product product, {int quantity = 1}) async {
    final current = quantityOf(product.id);
    final maxQty = max(product.stock, 1);
    final newQty = min(current + quantity, maxQty);

    final item = CartItem.fromProduct(product, quantity: newQty);
    _items[product.id] = item; // cap nhat UI truoc (optimistic update)
    notifyListeners();
    await _repository.upsert(item);
  }

  Future<void> updateQuantity(int productId, int quantity) async {
    final existing = _items[productId];
    if (existing == null) return;
    if (quantity <= 0) return remove(productId);

    final item = existing.copyWith(quantity: min(quantity, max(existing.stock, 1)));
    _items[productId] = item;
    notifyListeners();
    await _repository.upsert(item);
  }

  Future<void> remove(int productId) async {
    if (_items.remove(productId) == null) return;
    notifyListeners();
    await _repository.remove(productId);
  }

  /// Gia lap dat hang: xoa gio sau khi "thanh toan".
  Future<void> checkout() async {
    _items.clear();
    notifyListeners();
    await _repository.clear();
  }
}
