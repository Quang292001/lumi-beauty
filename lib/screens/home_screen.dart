import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../providers/paged_products_provider.dart';
import '../services/product_service.dart';
import '../widgets/paged_product_grid.dart';
import 'search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: kCategories.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lumi Beauty', style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(104),
            child: Column(
              children: [
                const _SearchBarButton(),
                TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  indicatorColor: Colors.white,
                  dividerColor: Colors.transparent,
                  tabs: kCategories.map((c) => Tab(text: c.label)).toList(),
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: kCategories.map((c) => _CategoryTab(category: c)).toList(),
        ),
      ),
    );
  }
}

/// O tim kiem gia: bam vao thi mo SearchScreen.
class _SearchBarButton extends StatelessWidget {
  const _SearchBarButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SearchScreen()),
          ),
          child: const SizedBox(
            height: 44,
            child: Row(
              children: [
                SizedBox(width: 12),
                Icon(Icons.search, color: Colors.grey),
                SizedBox(width: 8),
                Text('Tìm son, serum, nước hoa...', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Moi tab giu 1 PagedProductsProvider rieng va duoc "keep alive"
/// de khong tai lai khi chuyen qua lai giua cac tab.
class _CategoryTab extends StatefulWidget {
  const _CategoryTab({required this.category});

  final AppCategory category;

  @override
  State<_CategoryTab> createState() => _CategoryTabState();
}

class _CategoryTabState extends State<_CategoryTab> with AutomaticKeepAliveClientMixin {
  late final PagedProductsProvider _provider;

  @override
  void initState() {
    super.initState();
    final service = context.read<ProductService>();
    _provider = PagedProductsProvider(
      (skip, limit) => service.getByCategory(widget.category.slug, skip: skip, limit: limit),
    )..loadFirstPage();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ChangeNotifierProvider.value(
      value: _provider,
      child: const PagedProductGrid(),
    );
  }
}
