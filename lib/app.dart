import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/api_client.dart';
import 'core/theme.dart';
import 'data/cart_repository.dart';
import 'data/favorite_repository.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/favorite_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'services/auth_service.dart';
import 'services/product_service.dart';

class LumiBeautyApp extends StatelessWidget {
  const LumiBeautyApp({super.key, required this.apiClient});

  final ApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    // Dependency Injection don gian bang Provider:
    // service (khong doi) dung Provider, state (thay doi) dung ChangeNotifierProvider.
    return MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        Provider<ProductService>(create: (_) => ProductService(apiClient)),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(AuthService(apiClient), apiClient)..tryAutoLogin(),
        ),
        ChangeNotifierProvider<CartProvider>(
          create: (_) => CartProvider(SqfliteCartRepository())..load(),
        ),
        ChangeNotifierProvider<FavoriteProvider>(
          create: (_) => FavoriteProvider(SqfliteFavoriteRepository())..load(),
        ),
      ],
      child: MaterialApp(
        title: 'Lumi Beauty',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const AuthGate(),
      ),
    );
  }
}

/// Dieu huong theo trang thai dang nhap.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.select<AuthProvider, AuthStatus>((a) => a.status);
    return switch (status) {
      AuthStatus.unknown => const _SplashScreen(),
      AuthStatus.authenticated => const MainShell(),
      AuthStatus.unauthenticated => const LoginScreen(),
    };
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.spa_rounded, size: 80, color: Colors.white),
            SizedBox(height: 16),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
