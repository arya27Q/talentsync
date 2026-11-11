import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'api_exception.dart';

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();
  static const _tokenKey = 'access_token';
  static const _userKey = 'session_user';
  static const _storage = FlutterSecureStorage();
  static const _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get _baseUrl {
    if (_configuredBaseUrl.isNotEmpty) return _configuredBaseUrl;
    if (kIsWeb) return 'http://127.0.0.1:8000/api';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://127.0.0.1:8000/api';
  }

  final http.Client _client = http.Client();

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
    bool authenticated = true,
  }) => _send('GET', path, query: query, authenticated: authenticated);

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) => _send('POST', path, body: body, authenticated: authenticated);

  Future<Map<String, dynamic>> postMultipart(
    String path, {
    Map<String, String>? fields,
    required String fileField,
    required String fileName,
    required Uint8List fileBytes,
    bool authenticated = true,
  }) async {
    final uri = _buildUri(path);
    final request = http.MultipartRequest('POST', uri);
    if (fields != null) {
      request.fields.addAll(fields);
    }
    request.files.add(
      http.MultipartFile.fromBytes(
        fileField,
        fileBytes,
        filename: fileName,
      ),
    );
    return _executeRequest(request, authenticated: authenticated);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) => _send('PUT', path, body: body, authenticated: authenticated);

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) => _send('PATCH', path, body: body, authenticated: authenticated);

  Future<void> delete(String path) async {
    await _send('DELETE', path);
  }

  Future<void> saveSession({
    required String token,
    required Map<String, dynamic> user,
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userKey, value: jsonEncode(user));
  }

  Future<Map<String, dynamic>?> readSessionUser() async {
    final value = await _storage.read(key: _userKey);
    if (value == null) return null;
    final decoded = jsonDecode(value);
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  Uri _buildUri(String path, {Map<String, String>? query}) {
    final normalizedBase = _baseUrl.endsWith('/') ? _baseUrl : '$_baseUrl/';
    final base = Uri.parse(normalizedBase);
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    return base.resolve(normalizedPath).replace(queryParameters: query);
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    final uri = _buildUri(path, query: query);
    final request = http.Request(method, uri)
      ..headers['Content-Type'] = 'application/json';
    if (body != null) request.body = jsonEncode(body);
    return _executeRequest(request, authenticated: authenticated);
  }

  Future<Map<String, dynamic>> _executeRequest(
    http.BaseRequest request, {
    required bool authenticated,
  }) async {
    request.headers['Accept'] = 'application/json';

    if (authenticated) {
      final token = await _storage.read(key: _tokenKey);
      if (token == null || token.isEmpty) {
        throw const ApiException(
          'Sesi login tidak ditemukan. Silakan masuk kembali.',
        );
      }
      request.headers['Authorization'] = 'Bearer $token';
    }

    try {
      final streamed = await _client
          .send(request)
          .timeout(const Duration(seconds: 20));
      final response = await http.Response.fromStream(streamed);
      final decoded = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body);
      final payload = decoded is Map<String, dynamic>
          ? decoded
          : <String, dynamic>{};

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          payload['message'] as String? ?? 'Permintaan gagal. Coba lagi.',
          statusCode: response.statusCode,
          errors: payload['errors'] is Map<String, dynamic>
              ? payload['errors'] as Map<String, dynamic>
              : null,
        );
      }

      return payload;
    } on ApiException {
      rethrow;
    } on FormatException {
      throw const ApiException('Respons server tidak dapat dibaca.');
    } on TimeoutException {
      throw const ApiException('Server terlalu lama merespons. Coba lagi.');
    } on Exception catch (error) {
      if (error is http.ClientException) {
        throw const ApiException(
          'Server tidak dapat dijangkau. Periksa koneksi dan alamat API.',
        );
      }
      rethrow;
    }
  }
}
