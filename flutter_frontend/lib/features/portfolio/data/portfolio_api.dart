import 'package:flutter_frontend/core/network/api_client.dart';

class PortfolioApi {
  PortfolioApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  static final PortfolioApi instance = PortfolioApi();
  final ApiClient _client;

  Future<Map<String, dynamic>> portfolio() async =>
      (await _client.get('/student/portfolio'))['data'] as Map<String, dynamic>;

  Future<Map<String, dynamic>> caseStudy(int portfolioId) async =>
      (await _client.get('/portfolio/case-studies/$portfolioId'))['data']
          as Map<String, dynamic>;

  Future<Map<String, dynamic>> certificates() async =>
      (await _client.get('/student/certificates'))['data']
          as Map<String, dynamic>;

  Future<Map<String, dynamic>> syncGithub({String? username}) async =>
      (await _client.post(
            '/student/portfolio/github/sync',
            body: {
              if (username != null && username.trim().isNotEmpty)
                'github_username': username.trim(),
            },
          ))['data']
          as Map<String, dynamic>;

  Future<void> disconnectGithub() async =>
      _client.delete('/student/portfolio/github');

  Future<Map<String, dynamic>> verifySkill(int skillId) async =>
      (await _client.post('/student/skills/$skillId/verify'))['data']
          as Map<String, dynamic>;
}

