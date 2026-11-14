import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api_client.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._service, this._api);

  static const String _tokenKey = 'access_token';

  final AuthService _service;
  final ApiClient _api;

  AuthStatus _status = AuthStatus.unknown;
  User? _user;
  bool _isLoading = false;
  String? _error;

  AuthStatus get status => _status;
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Goi luc mo app: neu da co token thi kiem tra con hieu luc khong.
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    _api.setToken(token);
    try {
      _user = await _service.getCurrentUser();
      _status = AuthStatus.authenticated;
    } catch (_) {
      // Token het han / loi mang -> yeu cau dang nhap lai.
      await prefs.remove(_tokenKey);
      _api.setToken(null);
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _service.login(username.trim(), password);
      final token = user.accessToken;
      if (token == null) throw ApiException('Không nhận được token.');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      _api.setToken(token);

      _user = user;
      _status = AuthStatus.authenticated;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    _api.setToken(null);
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
