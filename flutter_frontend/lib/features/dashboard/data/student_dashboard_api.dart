import 'package:flutter_frontend/core/network/api_client.dart';

class StudentDashboardApi {
  StudentDashboardApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  static final StudentDashboardApi instance = StudentDashboardApi();
  final ApiClient _client;

  Future<Map<String, dynamic>> dashboard() async =>
      (await _client.get('/student/dashboard'))['data'] as Map<String, dynamic>;
}

