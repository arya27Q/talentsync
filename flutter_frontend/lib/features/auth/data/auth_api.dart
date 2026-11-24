import 'dart:typed_data';
import 'package:http/http.dart' as http;

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
    String? avatarFileName,
    Uint8List? avatarBytes,
    String? avatarUrl,
    String? cohortYear,
    String? bio,
    List<String>? skills,
  }) async {
    late final Map<String, dynamic> response;
    final hasKtmFile = ktmFileName != null && ktmBytes != null;
    final hasAvatarFile = avatarFileName != null && avatarBytes != null;

    if (hasKtmFile || hasAvatarFile) {
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
        if (avatarUrl != null && avatarUrl.trim().isNotEmpty)
          'avatar_url': avatarUrl.trim(),
        if (ktmDocumentUrl != null && ktmDocumentUrl.trim().isNotEmpty)
          'ktm_document_url': ktmDocumentUrl.trim(),
      };
      if (skills != null) {
        for (var i = 0; i < skills.length; i++) {
          fields['skills[$i]'] = skills[i];
        }
      }

      String? primaryFileField;
      String? primaryFileName;
      Uint8List? primaryFileBytes;
      final extraFiles = <http.MultipartFile>[];

      if (hasKtmFile) {
        primaryFileField = 'ktm_file';
        primaryFileName = ktmFileName;
        primaryFileBytes = ktmBytes;
        if (hasAvatarFile) {
          extraFiles.add(
            http.MultipartFile.fromBytes(
              'avatar_file',
              avatarBytes,
              filename: avatarFileName,
            ),
          );
        }
      } else {
        primaryFileField = 'avatar_file';
        primaryFileName = avatarFileName;
        primaryFileBytes = avatarBytes;
      }

      response = await _client.postMultipart(
        '/auth/register',
        authenticated: false,
        fields: fields,
        fileField: primaryFileField,
        fileName: primaryFileName,
        fileBytes: primaryFileBytes,
        extraFiles: extraFiles,
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
          if (avatarUrl != null && avatarUrl.trim().isNotEmpty)
            'avatar_url': avatarUrl.trim(),
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

  Future<Map<String, dynamic>> registerMsme({
    required String name,
    required String email,
    required String password,
    required String businessName,
    required String businessSector,
    String? address,
    String? city,
    String? description,
    String? phone,
    String? nib,
    String? logoFileName,
    Uint8List? logoBytes,
    String? logoUrl,
  }) async {
    late final Map<String, dynamic> response;

    if (logoFileName != null && logoBytes != null) {
      final fields = <String, String>{
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
        'password_confirmation': password,
        'role': 'msme',
        'business_name': businessName.trim(),
        'business_sector': businessSector.trim(),
        'address': (address ?? 'Surabaya').trim(),
        if (city != null && city.trim().isNotEmpty) 'city': city.trim(),
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
        if (nib != null && nib.trim().isNotEmpty) 'nib': nib.trim(),
      };
      response = await _client.postMultipart(
        '/auth/register',
        authenticated: false,
        fields: fields,
        fileField: 'logo_file',
        fileName: logoFileName,
        fileBytes: logoBytes,
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
          'role': 'msme',
          'business_name': businessName.trim(),
          'business_sector': businessSector.trim(),
          'address': (address ?? 'Surabaya').trim(),
          if (city != null && city.trim().isNotEmpty) 'city': city.trim(),
          if (description != null && description.trim().isNotEmpty)
            'description': description.trim(),
          if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
          if (nib != null && nib.trim().isNotEmpty) 'nib': nib.trim(),
          if (logoUrl != null && logoUrl.trim().isNotEmpty)
            'logo_url': logoUrl.trim(),
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
    String? avatarFileName,
    Uint8List? avatarBytes,
    String? avatarUrl,
  }) async {
    final fields = <String, String>{
      'name': name.trim(),
      'email': email.trim(),
      'password': password,
      'password_confirmation': password,
      'title_headline': titleHeadline.trim(),
      'bio': bio.trim(),
      'hourly_rate_tc': '$hourlyRateTc',
      'portfolio_url': portfolioUrl.trim(),
      if (avatarUrl != null && avatarUrl.trim().isNotEmpty)
        'avatar_url': avatarUrl.trim(),
    };

    final extraFiles = <http.MultipartFile>[];
    if (avatarFileName != null && avatarBytes != null) {
      extraFiles.add(
        http.MultipartFile.fromBytes(
          'avatar_file',
          avatarBytes,
          filename: avatarFileName,
        ),
      );
    }

    final response = await _client.postMultipart(
      '/auth/register-mentor',
      authenticated: false,
      fields: fields,
      fileField: 'cv_file',
      fileName: cvFileName,
      fileBytes: cvBytes,
      extraFiles: extraFiles,
    );
    final data = response['data'] as Map<String, dynamic>;
    final user = data['user'] as Map<String, dynamic>;
    return user;
  }

  Future<Map<String, dynamic>> me() async =>
      (await _client.get('/auth/me'))['data'] as Map<String, dynamic>;

  Future<Map<String, dynamic>> switchRole(String role) async {
    final response = await _client.post(
      '/auth/switch-role',
      body: {'role': role},
    );
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
    final response = await _client.sendDeleteWithResponse(
      '/auth/sessions/others',
    );
    return (response['message'] as String?) ??
        'Sesi perangkat lain dikeluarkan.';
  }

  Future<void> logout() async {
    try {
      await _client.post('/auth/logout');
    } catch (_) {
      // Abaikan error jaringan atau token invalid di server saat logout.
      // Sesi lokal tetap wajib dibersihkan secara tuntas.
    } finally {
      await _client.clearSession();
    }
  }
}
