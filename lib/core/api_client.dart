import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'constants.dart';

/// Loi tra ve tu tang network, message da duoc Viet hoa de hien thi cho user.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Wrapper quanh package `http`:
/// - gan base URL, header JSON va Bearer token
/// - timeout
/// - parse JSON + chuyen moi loi ve [ApiException]
class ApiClient {
  ApiClient({http.Client? client, this.baseUrl = ApiConstants.baseUrl})
      : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;
  String? _token;

  void setToken(String? token) => _token = token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Uri _buildUri(String path, Map<String, String>? query) {
    final uri = Uri.parse('$baseUrl$path');
    return query == null ? uri : uri.replace(queryParameters: query);
  }

  Future<dynamic> get(String path, {Map<String, String>? query}) {
    return _send(() => _client.get(_buildUri(path, query), headers: _headers));
  }

  Future<dynamic> post(String path, {Object? body}) {
    return _send(
      () => _client.post(
        _buildUri(path, null),
        headers: _headers,
        body: jsonEncode(body),
      ),
    );
  }

  Future<dynamic> _send(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(ApiConstants.timeout);
      final dynamic data = response.bodyBytes.isEmpty
          ? null
          : jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      }

      final serverMessage =
          (data is Map && data['message'] is String) ? data['message'] as String : null;
      throw ApiException(
        _friendlyMessage(response.statusCode, serverMessage),
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw ApiException('Không có kết nối mạng. Vui lòng kiểm tra Internet.');
    } on TimeoutException {
      throw ApiException('Kết nối quá thời gian, vui lòng thử lại.');
    } on http.ClientException {
      throw ApiException('Không thể kết nối tới máy chủ.');
    } on FormatException {
      throw ApiException('Dữ liệu trả về không hợp lệ.');
    }
  }

  String _friendlyMessage(int statusCode, String? serverMessage) {
    switch (statusCode) {
      case 400:
        return serverMessage ?? 'Yêu cầu không hợp lệ.';
      case 401:
        return 'Phiên đăng nhập hết hạn hoặc sai thông tin.';
      case 404:
        return 'Không tìm thấy dữ liệu.';
      default:
        return serverMessage ?? 'Lỗi máy chủ ($statusCode).';
    }
  }
}
