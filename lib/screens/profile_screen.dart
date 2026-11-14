import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/favorite_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Huỷ')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Đăng xuất')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<AuthProvider>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final favoriteCount = context.select<FavoriteProvider, int>((f) => f.count);

    return Scaffold(
      appBar: AppBar(title: const Text('Tài khoản')),
      body: ListView(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: AppColors.primary.withAlpha(30),
                  backgroundImage: user?.image != null ? NetworkImage(user!.image!) : null,
                  child: user?.image == null ? const Icon(Icons.person, size: 34) : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? 'Khách',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(user?.email ?? '', style: const TextStyle(color: AppColors.textMuted)),
                      Text('@${user?.username ?? ''}', style: const TextStyle(color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.receipt_long_outlined),
                  title: Text('Đơn hàng của tôi'),
                  subtitle: Text('Sắp ra mắt'),
                  enabled: false,
                ),
                ListTile(
                  leading: const Icon(Icons.favorite_border),
                  title: const Text('Sản phẩm yêu thích'),
                  trailing: Text('$favoriteCount'),
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Về ứng dụng'),
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: 'Lumi Beauty',
                    applicationVersion: '1.0.0',
                    children: const [
                      Text('Project cá nhân viết bằng Flutter: REST API (DummyJSON), '
                          'Provider, SQLite (sqflite), JWT.'),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
                  onTap: () => _confirmLogout(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
