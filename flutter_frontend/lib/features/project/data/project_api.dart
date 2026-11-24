import 'dart:typed_data';

import 'package:flutter_frontend/core/network/api_client.dart';

class ProjectApi {
  ProjectApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  static final ProjectApi instance = ProjectApi();
  final ApiClient _client;

  Future<Map<String, dynamic>> explore({
    String? search,
    String? category,
    String? sort,
    bool mentorCertificateOnly = false,
    int page = 1,
  }) async {
    final query = <String, String>{
      'page': '$page',
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (category != null && category.trim().isNotEmpty && category != 'Semua')
        'category': category.trim(),
      if (sort != null && sort.trim().isNotEmpty) 'sort': sort.trim(),
      if (mentorCertificateOnly) 'mentor_certificate_only': '1',
    };
    return _client.get('/projects', query: query);
  }

  Future<Map<String, dynamic>> detail(int projectId) async =>
      (await _client.get('/projects/$projectId'))['data'] as Map<String, dynamic>;

  Future<bool> toggleBookmark(int projectId) async {
    final res = await _client.post('/projects/$projectId/bookmark');
    final data = res['data'] as Map<String, dynamic>;
    return data['is_bookmarked'] == true;
  }

  Future<Map<String, dynamic>> applyContext(int projectId) async =>
      (await _client.get('/projects/$projectId/apply-context'))['data']
          as Map<String, dynamic>;

  Future<Map<String, dynamic>> apply(
    int projectId, {
    required String coverLetter,
    List<int> portfolioIds = const [],
    String? portfolioLink,
    String? linkedinUrl,
    String? cvUrl,
    String? cvFileName,
    Uint8List? cvFileBytes,
    String? githubUrl,
    String? timelineCommitment,
    String? dedicationHours,
    bool commitmentAccepted = true,
  }) async {
    final hasCvFile = cvFileName != null && cvFileBytes != null;
    if (hasCvFile) {
      final fields = <String, String>{
        'cover_letter': coverLetter.trim(),
        'commitment_accepted': commitmentAccepted ? '1' : '0',
        if (portfolioLink != null && portfolioLink.trim().isNotEmpty)
          'portfolio_link': portfolioLink.trim(),
        if (linkedinUrl != null && linkedinUrl.trim().isNotEmpty)
          'linkedin_url': linkedinUrl.trim(),
        if (cvUrl != null && cvUrl.trim().isNotEmpty) 'cv_url': cvUrl.trim(),
        if (githubUrl != null && githubUrl.trim().isNotEmpty)
          'github_url': githubUrl.trim(),
        if (timelineCommitment != null && timelineCommitment.trim().isNotEmpty)
          'timeline_commitment': timelineCommitment.trim(),
        if (dedicationHours != null && dedicationHours.trim().isNotEmpty)
          'dedication_hours': dedicationHours.trim(),
      };
      for (var i = 0; i < portfolioIds.length; i++) {
        fields['portfolio_ids[$i]'] = '${portfolioIds[i]}';
      }
      final res = await _client.postMultipart(
        '/projects/$projectId/apply',
        fields: fields,
        fileField: 'cv_file',
        fileName: cvFileName,
        fileBytes: cvFileBytes,
      );
      return res['data'] as Map<String, dynamic>;
    }

    final res = await _client.post(
      '/projects/$projectId/apply',
      body: {
        'cover_letter': coverLetter.trim(),
        if (portfolioIds.isNotEmpty) 'portfolio_ids': portfolioIds,
        if (portfolioLink != null && portfolioLink.trim().isNotEmpty)
          'portfolio_link': portfolioLink.trim(),
        if (linkedinUrl != null && linkedinUrl.trim().isNotEmpty)
          'linkedin_url': linkedinUrl.trim(),
        if (cvUrl != null && cvUrl.trim().isNotEmpty) 'cv_url': cvUrl.trim(),
        if (githubUrl != null && githubUrl.trim().isNotEmpty)
          'github_url': githubUrl.trim(),
        'timeline_commitment': ?timelineCommitment,
        'dedication_hours': ?dedicationHours,
        'commitment_accepted': commitmentAccepted,
      },
    );
    return res['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> myProjects() async =>
      (await _client.get('/student/projects'))['data'] as Map<String, dynamic>;

  Future<Map<String, dynamic>> completionSummary(int projectId) async =>
      (await _client.get('/projects/$projectId/completion-summary'))['data']
          as Map<String, dynamic>;

  Future<Map<String, dynamic>> reviewClient(
    int projectId, {
    required int rating,
    String? reviewText,
  }) async =>
      (await _client.post(
            '/projects/$projectId/review-client',
            body: {
              'rating': rating,
              if (reviewText != null && reviewText.trim().isNotEmpty)
                'review_text': reviewText.trim(),
            },
          ))['data']
          as Map<String, dynamic>;
}
