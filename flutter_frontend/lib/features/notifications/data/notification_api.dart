import 'package:flutter_frontend/core/network/api_client.dart';

class NotificationApi {
  NotificationApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  static final NotificationApi instance = NotificationApi();
  final ApiClient _client;

  Future<Map<String, dynamic>> list({int page = 1}) async =>
      _client.get('/notifications', query: {'page': '$page'});

  Future<void> markRead(String id) async {
    await _client.patch('/notifications/$id/read');
  }

  Future<void> markAllRead() async {
    await _client.post('/notifications/mark-all-read');
  }
}

