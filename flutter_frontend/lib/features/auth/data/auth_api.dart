import 'package:flutter_frontend/core/network/api_client.dart';

class AuthApi {
  AuthApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      '/auth/login',
      authenticated: false,
      body: {'email': email.trim(), 'password': password},
    );
    final data = response['data'] as Map<String, dynamic>;
    final user = data['user'] as Map<String, dynamic>;
    await _client.saveSession(token: data['token'] as String, user: user);
    return user;
  }

  Future<Map<String, dynamic>> registerMentor({
    required String name,
    required String email,
    required String password,
    required String titleHeadline,
    required String bio,
    required int hourlyRateTc,
    required String verificationDocumentUrl,
    required String portfolioUrl,
  }) async {
    final response = await _client.post(
      '/auth/register-mentor',
      authenticated: false,
      body: {
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
        'password_confirmation': password,
        'title_headline': titleHeadline.trim(),
        'bio': bio.trim(),
        'hourly_rate_tc': hourlyRateTc,
        'verification_document_url': verificationDocumentUrl.trim(),
        'portfolio_url': portfolioUrl.trim(),
      },
    );
    final data = response['data'] as Map<String, dynamic>;
    final user = data['user'] as Map<String, dynamic>;
    return user;
  }

  Future<void> logout() async {
    try {
      await _client.post('/auth/logout');
    } finally {
      await _client.clearSession();
    }
  }
}
