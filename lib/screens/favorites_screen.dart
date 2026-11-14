import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/favorite_provider.dart';
import '../widgets/common.dart';
import '../widgets/product_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoriteProvider>();

    return Scaffold(
      appBar: AppBar(title: Text('Yêu thích (${favorites.count})')),
      body: favorites.items.isEmpty
          ? const EmptyView(
              icon: Icons.favorite_border_rounded,
              message: 'Chưa có sản phẩm yêu thích.\nBấm ♡ trên sản phẩm để lưu lại nhé!',
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: kProductGridDelegate,
              itemCount: favorites.items.length,
              itemBuilder: (_, i) => ProductCard(product: favorites.items[i]),
            ),
    );
  }
}
