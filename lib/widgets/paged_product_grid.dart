import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/paged_products_provider.dart';
import 'common.dart';
import 'product_card.dart';

/// Grid san pham + infinite scroll + pull-to-refresh.
/// Can co [PagedProductsProvider] o phia tren cay widget.
class PagedProductGrid extends StatelessWidget {
  const PagedProductGrid({super.key, this.emptyMessage = 'Không có sản phẩm nào.'});

  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PagedProductsProvider>();

    if (provider.isEmpty) {
      if (provider.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (provider.error != null) {
        return ErrorView(message: provider.error!, onRetry: provider.loadFirstPage);
      }
      if (!provider.hasMore) {
        return EmptyView(icon: Icons.search_off_rounded, message: emptyMessage);
      }
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // Con < 400px la cham day -> tai trang tiep theo.
        if (notification.metrics.axis == Axis.vertical &&
            notification.metrics.extentAfter < 400) {
          provider.loadMore();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: provider.loadFirstPage,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: SliverGrid(
                gridDelegate: kProductGridDelegate,
                delegate: SliverChildBuilderDelegate(
                  (context, index) => ProductCard(product: provider.items[index]),
                  childCount: provider.items.length,
                ),
              ),
            ),
            SliverToBoxAdapter(child: _Footer(provider: provider)),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.provider});

  final PagedProductsProvider provider;

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (provider.error != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Center(
          child: TextButton.icon(
            onPressed: provider.loadMore,
            icon: const Icon(Icons.refresh),
            label: const Text('Lỗi tải thêm - Thử lại'),
          ),
        ),
      );
    }
    if (!provider.hasMore && provider.items.isNotEmpty) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 24),
        child: Center(
          child: Text('Bạn đã xem hết sản phẩm', style: TextStyle(color: Colors.grey)),
        ),
      );
    }
    return const SizedBox(height: 16);
  }
}
