import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/product.dart';
import '../models/review.dart';
import '../providers/cart_provider.dart';
import '../providers/favorite_provider.dart';
import '../widgets/common.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  Product get _product => widget.product;

  Future<void> _addToCart() async {
    final messenger = ScaffoldMessenger.of(context);
    await context.read<CartProvider>().add(_product, quantity: _quantity);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Đã thêm $_quantity "${_product.title}" vào giỏ hàng'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final isFavorite = context.select<FavoriteProvider, bool>(
      (fav) => fav.isFavorite(_product.id),
    );
    final cartCount = context.select<CartProvider, int>((c) => c.totalQuantity);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 360,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            actions: [
              IconButton(
                tooltip: 'Yêu thích',
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.redAccent : null,
                ),
                onPressed: () => context.read<FavoriteProvider>().toggle(_product),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Badge(
                  isLabelVisible: cartCount > 0,
                  label: Text('$cartCount'),
                  offset: const Offset(-4, 4),
                  child: const IconButton(
                    onPressed: null,
                    icon: Icon(Icons.shopping_bag_outlined, color: Colors.black87),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _ImageGallery(images: _product.gallery),
            ),
          ),
          SliverToBoxAdapter(child: _buildInfo()),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFEDEEF0))),
          ),
          child: Row(
            children: [
              QuantitySelector(
                value: _quantity,
                max: _product.stock > 0 ? _product.stock : 1,
                onChanged: (v) => setState(() => _quantity = v),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _product.inStock ? _addToCart : null,
                  icon: const Icon(Icons.add_shopping_cart),
                  label: Text(_product.inStock ? 'Thêm vào giỏ' : 'Hết hàng'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfo() {
    final p = _product;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (p.brand != null)
            Text(
              p.brand!.toUpperCase(),
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          const SizedBox(height: 4),
          Text(p.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              RatingStars(rating: p.rating, size: 16),
              const SizedBox(width: 6),
              Text(
                '${p.rating.toStringAsFixed(1)}  ·  ${p.reviews.length} đánh giá',
                style: const TextStyle(color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          PriceText(salePrice: p.salePriceVnd, originalPrice: p.originalPriceVnd, large: true),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (p.hasDiscount)
                _Chip(text: 'Giảm ${p.discountPercentage.round()}%', color: AppColors.accent),
              _Chip(
                text: p.inStock ? 'Còn ${p.stock} sản phẩm' : 'Hết hàng',
                color: p.inStock ? AppColors.primary : Colors.red,
              ),
              const _Chip(text: 'Freeship đơn từ 500K', color: Colors.blueGrey),
            ],
          ),
          const Divider(height: 32),
          const Text('Mô tả sản phẩm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(p.description, style: const TextStyle(height: 1.5)),
          if (p.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              children: p.tags.map((t) => Chip(label: Text('#$t'))).toList(),
            ),
          ],
          const Divider(height: 32),
          Text(
            'Đánh giá (${p.reviews.length})',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          if (p.reviews.isEmpty)
            const Text('Chưa có đánh giá nào.', style: TextStyle(color: AppColors.textMuted))
          else
            ...p.reviews.map((r) => _ReviewTile(review: r)),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    final date = review.date;
    final dateText = date == null ? '' : '${date.day}/${date.month}/${date.year}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withAlpha(30),
            child: Text(
              review.reviewerName.isNotEmpty ? review.reviewerName[0] : '?',
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        review.reviewerName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(dateText, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 2),
                RatingStars(rating: review.rating.toDouble(), size: 13),
                const SizedBox(height: 4),
                Text(review.comment),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageGallery extends StatefulWidget {
  const _ImageGallery({required this.images});

  final List<String> images;

  @override
  State<_ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<_ImageGallery> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          itemCount: widget.images.length,
          onPageChanged: (i) => setState(() => _page = i),
          itemBuilder: (_, i) => NetImage(widget.images[i], fit: BoxFit.contain),
        ),
        if (widget.images.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.images.length, (i) {
                final active = i == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : Colors.black26,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}
