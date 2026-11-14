import '../core/api_client.dart';
import '../core/constants.dart';
import '../models/user.dart';

/// Dang nhap bang JWT cua DummyJSON.
class AuthService {
  AuthService(this._api);

  final ApiClient _api;

  /// POST /auth/login -> tra ve user kem accessToken
  Future<User> login(String username, String password) async {
    final json = await _api.post('/auth/login', body: {
      'username': username,
      'password': password,
      'expiresInMins': ApiConstants.tokenExpiresInMins,
    });
    return User.fromJson(json as Map<String, dynamic>);
  }

  /// GET /auth/me (can header Authorization: Bearer token)
  Future<User> getCurrentUser() async {
    final json = await _api.get('/auth/me');
    return User.fromJson(json as Map<String, dynamic>);
  }
}
