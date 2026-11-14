import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/paged_products_provider.dart';
import '../services/product_service.dart';
import '../widgets/paged_product_grid.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const _suggestions = ['mascara', 'lipstick', 'perfume', 'cream', 'oil', 'powder'];

  final _controller = TextEditingController();
  late final PagedProductsProvider _provider;
  Timer? _debounce;
  String _query = '';

  @override
  void initState() {
    super.initState();
    final service = context.read<ProductService>();
    // Tim kiem tra ve 1 trang duy nhat (da loc theo nhom lam dep).
    _provider = PagedProductsProvider((skip, limit) async {
      if (skip > 0) return ProductPage(products: const [], total: skip, skip: skip);
      final results = await service.searchBeauty(_query);
      return ProductPage(products: results, total: results.length, skip: 0);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _provider.dispose();
    super.dispose();
  }

  /// Debounce 400ms: chi goi API khi nguoi dung ngung go.
  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(value));
  }

  void _search(String value) {
    final q = value.trim();
    setState(() => _query = q);
    if (q.isNotEmpty) _provider.loadFirstPage();
  }

  void _useSuggestion(String s) {
    _controller.text = s;
    _controller.selection = TextSelection.collapsed(offset: s.length);
    _debounce?.cancel();
    _search(s);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onChanged: _onChanged,
          onSubmitted: (v) {
            _debounce?.cancel();
            _search(v);
          },
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            hintText: 'Tìm sản phẩm (tiếng Anh, vd: mascara)',
            hintStyle: const TextStyle(color: Colors.white70),
            filled: false,
            border: InputBorder.none,
            suffixIcon: _controller.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      _controller.clear();
                      _debounce?.cancel();
                      _search('');
                    },
                  ),
          ),
        ),
      ),
      body: _query.isEmpty
          ? _buildSuggestions()
          : ChangeNotifierProvider.value(
              value: _provider,
              child: PagedProductGrid(
                emptyMessage: 'Không tìm thấy sản phẩm cho "$_query".',
              ),
            ),
    );
  }

  Widget _buildSuggestions() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Gợi ý tìm kiếm', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _suggestions
              .map((s) => ActionChip(label: Text(s), onPressed: () => _useSuggestion(s)))
              .toList(),
        ),
      ],
    );
  }
}
