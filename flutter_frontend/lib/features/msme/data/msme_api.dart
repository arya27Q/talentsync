import 'dart:typed_data';

import 'package:flutter_frontend/core/network/api_client.dart';

class MsmeApi {
  MsmeApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  static final MsmeApi instance = MsmeApi();
  final ApiClient _client;

  Future<Map<String, dynamic>> getDashboard() async =>
      (await _client.get('/msme/dashboard'))['data'] as Map<String, dynamic>;

  Future<Map<String, dynamic>> getProfile() async =>
      (await _client.get('/msme/profile'))['data'] as Map<String, dynamic>;

  Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> body, {
    String? logoFileName,
    Uint8List? logoBytes,
  }) async {
    if (logoFileName != null && logoBytes != null) {
      final fields = <String, String>{'_method': 'PUT'};
      for (final entry in body.entries) {
        final value = entry.value;
        if (value != null) {
          fields[entry.key] = '$value';
        }
      }
      return (await _client.postMultipart(
            '/msme/profile',
            fields: fields,
            fileField: 'logo_file',
            fileName: logoFileName,
            fileBytes: logoBytes,
          ))['data']
          as Map<String, dynamic>;
    }
    return (await _client.put('/msme/profile', body: body))['data']
        as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getMyProjects({String? status}) async {
    final query = status != null && status.isNotEmpty ? '?status=$status' : '';
    final response = await _client.get('/msme/projects$query');
    final rows = response['data'];
    if (rows is! List) return const [];
    return rows.whereType<Map<String, dynamic>>().toList(growable: false);
  }

  Future<Map<String, dynamic>> createProject({
    required String title,
    required String category,
    required int rewardTc,
    String? description,
    String? division,
    int? deadlineDays,
    String? durationLabel,
    String? workMode,
    String? locationLabel,
    List<String>? deliverablesChecklist,
    List<String>? skills,
  }) async {
    final body = <String, dynamic>{
      'title': title.trim(),
      'category': category.trim(),
      'reward_tc': rewardTc,
      'description': (description != null && description.trim().isNotEmpty)
          ? description.trim()
          : 'Kebutuhan pengerjaan $title untuk Mitra UMKM.',
      if (division != null && division.trim().isNotEmpty)
        'division': division.trim(),
      'deadline_days': ?deadlineDays,
      if (durationLabel != null && durationLabel.trim().isNotEmpty)
        'duration_label': durationLabel.trim(),
      if (workMode != null && workMode.trim().isNotEmpty)
        'work_mode': workMode.trim(),
      if (locationLabel != null && locationLabel.trim().isNotEmpty)
        'location_label': locationLabel.trim(),
      if (deliverablesChecklist != null && deliverablesChecklist.isNotEmpty)
        'deliverables_checklist': deliverablesChecklist,
      if (skills != null && skills.isNotEmpty) 'skills': skills,
    };

    final response = await _client.post('/msme/projects', body: body);
    return (response['data'] as Map<String, dynamic>?) ?? {};
  }

  Future<Map<String, dynamic>> getProjectDetail(int projectId) async =>
      (await _client.get('/msme/projects/$projectId'))['data']
          as Map<String, dynamic>;

  Future<Map<String, dynamic>> updateProject(
    int projectId,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.put('/msme/projects/$projectId', body: body);
    return (response['data'] as Map<String, dynamic>?) ?? {};
  }

  Future<void> deleteProject(int projectId) async {
    await _client.delete('/msme/projects/$projectId');
  }

  Future<List<Map<String, dynamic>>> getApplicants({
    int? projectId,
    String filter = 'all',
  }) async {
    final queryParams = <String>[];
    if (projectId != null) {
      queryParams.add('project_id=$projectId');
    }
    if (filter != 'all') {
      queryParams.add('filter=$filter');
    }
    final qs = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
    final response = await _client.get('/msme/applicants$qs');
    final rows = response['data'];
    if (rows is! List) return const [];
    return rows.whereType<Map<String, dynamic>>().toList(growable: false);
  }

  Future<Map<String, dynamic>> getApplicantDetail(int applicationId) async =>
      (await _client.get('/msme/applicants/$applicationId'))['data']
          as Map<String, dynamic>;

  Future<Map<String, dynamic>> acceptApplicant(int applicationId) async =>
      await _client.post('/msme/applications/$applicationId/accept');

  Future<Map<String, dynamic>> rejectToMentor(
    int applicationId, {
    String? feedback,
  }) async =>
      await _client.post(
        '/msme/applications/$applicationId/reject-to-mentor',
        body: {
          if (feedback != null && feedback.trim().isNotEmpty)
            'feedback': feedback.trim(),
        },
      );

  Future<Map<String, dynamic>> getSubmissions({
    int? projectId,
    String status = 'submitted',
  }) async {
    final queryParams = <String>[];
    if (projectId != null) {
      queryParams.add('project_id=$projectId');
    }
    if (status.isNotEmpty) {
      queryParams.add('status=$status');
    }
    final qs = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
    final response = await _client.get('/msme/submissions$qs');
    return (response['data'] as Map<String, dynamic>?) ?? const {};
  }

  Future<Map<String, dynamic>> requestMilestoneRevision(
    int milestoneId, {
    required String revisionNotes,
    bool recommendMentorConsultation = false,
  }) async =>
      await _client.post(
        '/msme/milestones/$milestoneId/revision',
        body: {
          'revision_notes': revisionNotes.trim(),
          'recommend_mentor_consultation': recommendMentorConsultation,
        },
      );

  Future<Map<String, dynamic>> approveMilestone(
    int milestoneId, {
    int? rating,
    String? reviewText,
  }) async =>
      await _client.post(
        '/msme/milestones/$milestoneId/approve',
        body: {
          'rating': ?rating,
          if (reviewText != null && reviewText.trim().isNotEmpty)
            'review_text': reviewText.trim(),
        },
      );
}
