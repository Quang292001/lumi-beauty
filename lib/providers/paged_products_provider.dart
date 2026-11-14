import 'package:flutter/foundation.dart';

import '../models/product.dart';

typedef PageFetcher = Future<ProductPage> Function(int skip, int limit);

/// Quan ly 1 danh sach san pham co phan trang (infinite scroll).
/// Dung chung cho tung tab danh muc va man hinh tim kiem.
class PagedProductsProvider extends ChangeNotifier {
  PagedProductsProvider(this._fetchPage, {this.pageSize = 10});

  final PageFetcher _fetchPage;
  final int pageSize;

  final List<Product> _items = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;
  bool _disposed = false;

  /// Moi lan reset tang len 1; ket qua cua request cu se bi bo qua
  /// (tranh truong hop go tim kiem nhanh, ket qua cu ve sau de len ket qua moi).
  int _generation = 0;

  List<Product> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;
  bool get isEmpty => _items.isEmpty;

  /// Tai lai tu dau (pull-to-refresh, doi tu khoa tim kiem...).
  Future<void> loadFirstPage() {
    _generation++;
    _items.clear();
    _hasMore = true;
    _isLoading = false;
    _error = null;
    return loadMore();
  }

  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;

    final generation = _generation;
    _isLoading = true;
    _error = null;
    _notify();

    try {
      final page = await _fetchPage(_items.length, pageSize);
      if (generation != _generation) return;
      _items.addAll(page.products);
      _hasMore = page.hasMore;
    } catch (e) {
      if (generation != _generation) return;
      _error = e.toString();
    } finally {
      if (generation == _generation) {
        _isLoading = false;
        _notify();
      }
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
