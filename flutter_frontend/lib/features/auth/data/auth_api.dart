import 'dart:typed_data';

import 'package:flutter_frontend/core/network/api_client.dart';

class AuthApi {
  AuthApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<Map<String, dynamic>> login({
    String? email,
    String? identifier,
    required String password,
  }) async {
    final loginIdentifier = (identifier ?? email ?? '').trim();
    final response = await _client.post(
      '/auth/login',
      authenticated: false,
      body: {
        'identifier': loginIdentifier,
        if (loginIdentifier.contains('@')) 'email': loginIdentifier,
        'password': password,
      },
    );
    final data = response['data'] as Map<String, dynamic>;
    final user = data['user'] as Map<String, dynamic>;
    await _client.saveSession(token: data['token'] as String, user: user);
    return user;
  }

  Future<Map<String, dynamic>> registerStudent({
    required String name,
    required String email,
    required String password,
    required String university,
    required String major,
    required String studentIdNumber,
    String? ktmFileName,
    Uint8List? ktmBytes,
    String? ktmDocumentUrl,
    String? cohortYear,
    String? bio,
    List<String>? skills,
  }) async {
    late final Map<String, dynamic> response;
    if (ktmFileName != null && ktmBytes != null) {
      final fields = <String, String>{
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
        'password_confirmation': password,
        'role': 'student',
        'university': university.trim(),
        'major': major.trim(),
        'student_id_number': studentIdNumber.trim(),
        if (cohortYear != null && cohortYear.trim().isNotEmpty)
          'cohort_year': cohortYear.trim(),
        if (bio != null && bio.trim().isNotEmpty) 'bio': bio.trim(),
      };
      if (skills != null) {
        for (var i = 0; i < skills.length; i++) {
          fields['skills[$i]'] = skills[i];
        }
      }
      response = await _client.postMultipart(
        '/auth/register',
        authenticated: false,
        fields: fields,
        fileField: 'ktm_file',
        fileName: ktmFileName,
        fileBytes: ktmBytes,
      );
    } else {
      response = await _client.post(
        '/auth/register',
        authenticated: false,
        body: {
          'name': name.trim(),
          'email': email.trim(),
          'password': password,
          'password_confirmation': password,
          'role': 'student',
          'university': university.trim(),
          'major': major.trim(),
          'student_id_number': studentIdNumber.trim(),
          if (ktmDocumentUrl != null && ktmDocumentUrl.trim().isNotEmpty)
            'ktm_document_url': ktmDocumentUrl.trim(),
          if (cohortYear != null && cohortYear.trim().isNotEmpty)
            'cohort_year': cohortYear.trim(),
          if (bio != null && bio.trim().isNotEmpty) 'bio': bio.trim(),
          if (skills != null && skills.isNotEmpty) 'skills': skills,
        },
      );
    }

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
    required String cvFileName,
    required Uint8List cvBytes,
    required String portfolioUrl,
  }) async {
    final response = await _client.postMultipart(
      '/auth/register-mentor',
      authenticated: false,
      fields: {
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
        'password_confirmation': password,
        'title_headline': titleHeadline.trim(),
        'bio': bio.trim(),
        'hourly_rate_tc': '$hourlyRateTc',
        'portfolio_url': portfolioUrl.trim(),
      },
      fileField: 'cv_file',
      fileName: cvFileName,
      fileBytes: cvBytes,
    );
    final data = response['data'] as Map<String, dynamic>;
    final user = data['user'] as Map<String, dynamic>;
    return user;
  }

  Future<Map<String, dynamic>> me() async =>
      (await _client.get('/auth/me'))['data'] as Map<String, dynamic>;

  Future<Map<String, dynamic>> switchRole(String role) async {
    final response = await _client.post('/auth/switch-role', body: {'role': role});
    final data = response['data'] as Map<String, dynamic>;
    final user = data['user'] as Map<String, dynamic>;
    await _client.updateSessionUser(user);
    return user;
  }

  Future<List<Map<String, dynamic>>> sessions() async {
    final rows = (await _client.get('/auth/sessions'))['data'];
    if (rows is! List) return const [];
    return rows.whereType<Map<String, dynamic>>().toList(growable: false);
  }

  Future<String> revokeOtherSessions() async {
    final response = await _client.sendDeleteWithResponse('/auth/sessions/others');
    return (response['message'] as String?) ?? 'Sesi perangkat lain dikeluarkan.';
  }

  Future<void> logout() async {
    try {
      await _client.post('/auth/logout');
    } finally {
      await _client.clearSession();
    }
  }
}
