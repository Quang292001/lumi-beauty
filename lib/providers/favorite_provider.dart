import 'package:flutter/foundation.dart';

import '../data/favorite_repository.dart';
import '../models/product.dart';

class FavoriteProvider extends ChangeNotifier {
  FavoriteProvider(this._repository);

  final FavoriteRepository _repository;

  // LinkedHashMap mac dinh giu thu tu them vao.
  final Map<int, Product> _items = {};

  List<Product> get items => _items.values.toList().reversed.toList();
  int get count => _items.length;

  bool isFavorite(int productId) => _items.containsKey(productId);

  Future<void> load() async {
    final saved = await _repository.getAll();
    _items.clear();
    // getAll tra ve moi nhat truoc -> dao lai de map giu thu tu cu -> moi.
    for (final p in saved.reversed) {
      _items[p.id] = p;
    }
    notifyListeners();
  }

  Future<void> toggle(Product product) async {
    if (isFavorite(product.id)) {
      _items.remove(product.id);
      notifyListeners();
      await _repository.remove(product.id);
    } else {
      _items[product.id] = product;
      notifyListeners();
      await _repository.add(product);
    }
  }
}
