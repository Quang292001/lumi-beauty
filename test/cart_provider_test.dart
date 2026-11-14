import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_beauty/core/constants.dart';
import 'package:lumi_beauty/providers/cart_provider.dart';

import 'helpers.dart';

void main() {
  late FakeCartRepository repo;
  late CartProvider cart;

  setUp(() {
    repo = FakeCartRepository();
    cart = CartProvider(repo);
  });

  test('them cung 1 san pham 2 lan thi cong don so luong', () async {
    final p = fakeProduct();
    await cart.add(p);
    await cart.add(p, quantity: 2);

    expect(cart.items.length, 1);
    expect(cart.quantityOf(p.id), 3);
    expect(repo.store[p.id]?.quantity, 3); // da luu xuong repository
  });

  test('so luong khong vuot qua ton kho', () async {
    final p = fakeProduct(stock: 2);
    await cart.add(p, quantity: 5);
    expect(cart.quantityOf(p.id), 2);

    await cart.updateQuantity(p.id, 10);
    expect(cart.quantityOf(p.id), 2);
  });

  test('cap nhat so luong ve 0 thi xoa khoi gio', () async {
    final p = fakeProduct();
    await cart.add(p);
    await cart.updateQuantity(p.id, 0);

    expect(cart.isEmpty, isTrue);
    expect(repo.store, isEmpty);
  });

  test('tinh tong tien va phi van chuyen', () async {
    // 10 USD = 250.000d
    await cart.add(fakeProduct(id: 1, price: 10));
    expect(cart.subtotalVnd, 250000);
    expect(cart.shippingFeeVnd, kShippingFee);
    expect(cart.grandTotalVnd, 250000 + kShippingFee);

    // them 1 san pham nua -> 500.000d -> freeship
    await cart.add(fakeProduct(id: 2, price: 10));
    expect(cart.subtotalVnd, 500000);
    expect(cart.shippingFeeVnd, 0);
    expect(cart.totalQuantity, 2);
  });

  test('load lai gio hang tu repository (mo lai app)', () async {
    await cart.add(fakeProduct(id: 1), quantity: 2);
    final reopened = CartProvider(repo);
    await reopened.load();
    expect(reopened.quantityOf(1), 2);
  });

  test('checkout xoa sach gio hang', () async {
    await cart.add(fakeProduct(id: 1));
    await cart.add(fakeProduct(id: 2));
    await cart.checkout();
    expect(cart.isEmpty, isTrue);
    expect(cart.shippingFeeVnd, 0);
    expect(repo.store, isEmpty);
  });
}
