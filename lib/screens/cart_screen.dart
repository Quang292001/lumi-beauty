import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../core/formatters.dart';
import '../core/theme.dart';
import '../models/cart_item.dart';
import '../providers/cart_provider.dart';
import '../widgets/common.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key, this.onContinueShopping});

  /// Callback de MainShell chuyen ve tab Trang chu.
  final VoidCallback? onContinueShopping;

  Future<void> _checkout(BuildContext context, CartProvider cart) async {
    final total = cart.grandTotalVnd;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận đặt hàng'),
        content: Text('Tổng thanh toán: ${formatVnd(total)}\nThanh toán khi nhận hàng (COD).'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Huỷ')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Đặt hàng')),
        ],
      ),
    );
    if (confirmed != true) return;

    await cart.checkout();
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: AppColors.primary, size: 56),
        title: const Text('Đặt hàng thành công!'),
        content: const Text('Cảm ơn bạn đã mua sắm tại Lumi Beauty.'),
        actions: [
          FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: Text('Giỏ hàng (${cart.totalQuantity})')),
      body: cart.isEmpty
          ? EmptyView(
              icon: Icons.shopping_bag_outlined,
              message: 'Giỏ hàng của bạn đang trống.',
              action: onContinueShopping == null
                  ? null
                  : OutlinedButton(
                      onPressed: onContinueShopping,
                      child: const Text('Tiếp tục mua sắm'),
                    ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: cart.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _CartItemTile(item: cart.items[i]),
            ),
      bottomNavigationBar: cart.isEmpty ? null : _Summary(cart: cart, onCheckout: () => _checkout(context, cart)),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();

    // Vuot sang trai de xoa.
    return Dismissible(
      key: ValueKey(item.productId),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => cart.remove(item.productId),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(width: 80, height: 80, child: NetImage(item.thumbnail)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(
                    formatVnd(item.unitPriceVnd),
                    style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      QuantitySelector(
                        value: item.quantity,
                        max: item.stock > 0 ? item.stock : 1,
                        onChanged: (q) => cart.updateQuantity(item.productId, q),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Xoá',
                        icon: const Icon(Icons.delete_outline, color: AppColors.textMuted),
                        onPressed: () => cart.remove(item.productId),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.cart, required this.onCheckout});

  final CartProvider cart;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final remaining = kFreeShippingThreshold - cart.subtotalVnd;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFEDEEF0))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (remaining > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Mua thêm ${formatVnd(remaining)} để được miễn phí vận chuyển',
                  style: const TextStyle(color: AppColors.primary, fontSize: 12),
                ),
              ),
            _row('Tạm tính', formatVnd(cart.subtotalVnd)),
            _row(
              'Phí vận chuyển',
              cart.shippingFeeVnd == 0 ? 'Miễn phí' : formatVnd(cart.shippingFeeVnd),
            ),
            const Divider(),
            _row('Tổng cộng', formatVnd(cart.grandTotalVnd), bold: true),
            const SizedBox(height: 10),
            FilledButton(onPressed: onCheckout, child: const Text('Đặt hàng')),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      fontSize: bold ? 16 : 14,
      color: bold ? AppColors.accent : null,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text(value, style: style)],
      ),
    );
  }
}
