import 'dart:typed_data';

import 'package:flutter_frontend/core/network/api_client.dart';

class StudentProfileApi {
  StudentProfileApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  static final StudentProfileApi instance = StudentProfileApi();
  final ApiClient _client;

  Future<Map<String, dynamic>> profile() async =>
      (await _client.get('/student/profile'))['data'] as Map<String, dynamic>;

  Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> body, {
    String? fileField,
    String? fileName,
    Uint8List? fileBytes,
  }) async {
    if (fileField != null && fileName != null && fileBytes != null) {
      final fields = <String, String>{'_method': 'PUT'};
      for (final entry in body.entries) {
        final value = entry.value;
        if (value is List) {
          for (var i = 0; i < value.length; i++) {
            fields['${entry.key}[$i]'] = '${value[i]}';
          }
        } else if (value != null) {
          fields[entry.key] = value is bool ? (value ? '1' : '0') : '$value';
        }
      }
      return (await _client.postMultipart(
            '/student/profile',
            fields: fields,
            fileField: fileField,
            fileName: fileName,
            fileBytes: fileBytes,
          ))['data']
          as Map<String, dynamic>;
    }

    return (await _client.put('/student/profile', body: body))['data']
        as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> privacy() async =>
      (await _client.get('/student/settings/privacy'))['data']
          as Map<String, dynamic>;

  Future<Map<String, dynamic>> updatePrivacy(Map<String, dynamic> body) async =>
      (await _client.patch('/student/settings/privacy', body: body))['data']
          as Map<String, dynamic>;

  Future<Map<String, dynamic>> updatePin(String pin) async =>
      (await _client.put('/student/security/pin', body: {'pin': pin}))['data']
          as Map<String, dynamic>;

  Future<Map<String, dynamic>> mentorEligibility() async =>
      (await _client.get('/student/mentor-eligibility'))['data']
          as Map<String, dynamic>;

  Future<Map<String, dynamic>> switchToMentor({
    required List<int> selectedProofIds,
    required List<String> teachingSkills,
    String? titleHeadline,
    String? bio,
    int hourlyRateTc = 30,
    String? externalCertFileName,
    Uint8List? externalCertBytes,
  }) async {
    if (externalCertFileName != null && externalCertBytes != null) {
      final fields = <String, String>{
        'hourly_rate_tc': '$hourlyRateTc',
        if (titleHeadline != null && titleHeadline.trim().isNotEmpty)
          'title_headline': titleHeadline.trim(),
        if (bio != null && bio.trim().isNotEmpty) 'bio': bio.trim(),
      };
      for (var i = 0; i < selectedProofIds.length; i++) {
        fields['selected_proof_ids[$i]'] = '${selectedProofIds[i]}';
      }
      for (var i = 0; i < teachingSkills.length; i++) {
        fields['teaching_skills[$i]'] = teachingSkills[i];
      }
      return (await _client.postMultipart(
            '/student/switch-to-mentor',
            fields: fields,
            fileField: 'external_certificate_file',
            fileName: externalCertFileName,
            fileBytes: externalCertBytes,
          ))['data']
          as Map<String, dynamic>;
    }

    return (await _client.post(
          '/student/switch-to-mentor',
          body: {
            'selected_proof_ids': selectedProofIds,
            'teaching_skills': teachingSkills,
            if (titleHeadline != null && titleHeadline.trim().isNotEmpty)
              'title_headline': titleHeadline.trim(),
            if (bio != null && bio.trim().isNotEmpty) 'bio': bio.trim(),
            'hourly_rate_tc': hourlyRateTc,
          },
        ))['data']
        as Map<String, dynamic>;
  }

  Future<void> deleteAccount() async {
    await _client.delete('/student/account');
    await _client.clearSession();
  }
}

