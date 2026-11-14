import '../core/formatters.dart';
import 'product.dart';

/// Mot dong trong gio hang. Luu vao bang SQLite `cart_items`.
class CartItem {
  const CartItem({
    required this.productId,
    required this.title,
    required this.thumbnail,
    required this.unitPriceVnd,
    required this.quantity,
    required this.stock,
  });

  final int productId;
  final String title;
  final String thumbnail;
  final int unitPriceVnd;
  final int quantity;
  final int stock;

  int get totalVnd => unitPriceVnd * quantity;

  factory CartItem.fromProduct(Product p, {required int quantity}) {
    return CartItem(
      productId: p.id,
      title: p.title,
      thumbnail: p.thumbnail,
      unitPriceVnd: p.salePriceVnd,
      quantity: quantity,
      stock: p.stock,
    );
  }

  CartItem copyWith({int? quantity}) => CartItem(
        productId: productId,
        title: title,
        thumbnail: thumbnail,
        unitPriceVnd: unitPriceVnd,
        quantity: quantity ?? this.quantity,
        stock: stock,
      );

  // ---- Map <-> SQLite row ----
  factory CartItem.fromMap(Map<String, Object?> map) => CartItem(
        productId: map['product_id'] as int,
        title: map['title'] as String,
        thumbnail: map['thumbnail'] as String,
        unitPriceVnd: map['unit_price'] as int,
        quantity: map['quantity'] as int,
        stock: map['stock'] as int,
      );

  Map<String, Object?> toMap() => {
        'product_id': productId,
        'title': title,
        'thumbnail': thumbnail,
        'unit_price': unitPriceVnd,
        'quantity': quantity,
        'stock': stock,
      };

  @override
  String toString() => 'CartItem($title x$quantity = ${formatVnd(totalVnd)})';
}
