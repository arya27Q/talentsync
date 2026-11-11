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
    String? timelineCommitment,
    String? dedicationHours,
    bool commitmentAccepted = true,
  }) async {
    final res = await _client.post(
      '/projects/$projectId/apply',
      body: {
        'cover_letter': coverLetter.trim(),
        if (portfolioIds.isNotEmpty) 'portfolio_ids': portfolioIds,
        if (portfolioLink != null && portfolioLink.trim().isNotEmpty)
          'portfolio_link': portfolioLink.trim(),
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
