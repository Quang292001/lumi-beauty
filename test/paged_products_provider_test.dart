import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_beauty/models/product.dart';
import 'package:lumi_beauty/providers/paged_products_provider.dart';

import 'helpers.dart';

void main() {
  /// Gia lap API co 25 san pham.
  Future<ProductPage> fakeApi(int skip, int limit) async {
    const total = 25;
    final end = min(skip + limit, total);
    return ProductPage(
      products: [for (var i = skip; i < end; i++) fakeProduct(id: i)],
      total: total,
      skip: skip,
    );
  }

  test('tai lan luot cac trang cho den het', () async {
    final provider = PagedProductsProvider(fakeApi, pageSize: 10);

    await provider.loadFirstPage();
    expect(provider.items.length, 10);
    expect(provider.hasMore, isTrue);

    await provider.loadMore();
    await provider.loadMore();
    expect(provider.items.length, 25);
    expect(provider.hasMore, isFalse);

    await provider.loadMore(); // het du lieu -> khong goi them
    expect(provider.items.length, 25);
  });

  test('loi mang -> luu error, thu lai thanh cong', () async {
    var shouldFail = true;
    final provider = PagedProductsProvider((skip, limit) async {
      if (shouldFail) throw Exception('network');
      return fakeApi(skip, limit);
    });

    await provider.loadFirstPage();
    expect(provider.error, isNotNull);
    expect(provider.isEmpty, isTrue);

    shouldFail = false;
    await provider.loadFirstPage();
    expect(provider.error, isNull);
    expect(provider.items.length, 10);
  });

  test('refresh bo qua ket qua cua request cu', () async {
    var call = 0;
    final provider = PagedProductsProvider((skip, limit) async {
      call++;
      final current = call;
      // request dau cham hon request sau
      await Future<void>.delayed(Duration(milliseconds: current == 1 ? 50 : 1));
      return ProductPage(products: [fakeProduct(id: current)], total: 1, skip: 0);
    });

    final first = provider.loadFirstPage();
    final second = provider.loadFirstPage();
    await Future.wait([first, second]);

    expect(provider.items.single.id, 2);
  });
}
