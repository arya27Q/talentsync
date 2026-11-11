import 'dart:typed_data';

import 'package:flutter_frontend/core/network/api_client.dart';

class WorkspaceApi {
  WorkspaceApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  static final WorkspaceApi instance = WorkspaceApi();
  final ApiClient _client;

  Future<Map<String, dynamic>> kanban(int projectId) async =>
      (await _client.get('/projects/$projectId/tasks'))['data']
          as Map<String, dynamic>;

  Future<Map<String, dynamic>> createTask(
    int projectId, {
    required String title,
    String tag = 'Fitur',
    String status = 'todo',
    String? deadlineLabel,
  }) async =>
      (await _client.post(
            '/projects/$projectId/tasks',
            body: {
              'title': title.trim(),
              'tag': tag,
              'status': status,
              'deadline_label': ?deadlineLabel,
            },
          ))['data']
          as Map<String, dynamic>;

  Future<Map<String, dynamic>> updateTask(
    int taskId,
    Map<String, dynamic> body,
  ) async =>
      (await _client.patch('/tasks/$taskId', body: body))['data']
          as Map<String, dynamic>;

  Future<void> deleteTask(int taskId) async => _client.delete('/tasks/$taskId');

  Future<Map<String, dynamic>> milestones(int projectId) async =>
      (await _client.get('/projects/$projectId/milestones'))['data']
          as Map<String, dynamic>;

  Future<Map<String, dynamic>> addMilestone(
    int projectId, {
    required String title,
    required int rewardTc,
    String? description,
  }) async =>
      (await _client.post(
            '/projects/$projectId/milestones',
            body: {
              'title': title.trim(),
              'reward_tc': rewardTc,
              if (description != null && description.trim().isNotEmpty)
                'description': description.trim(),
            },
          ))['data']
          as Map<String, dynamic>;

  Future<Map<String, dynamic>> submitDeliverable(
    int milestoneId, {
    String submissionFormat = 'link',
    String? deliverableUrl,
    String? submissionNotes,
    List<String> attachmentLinks = const [],
    String? fileName,
    Uint8List? fileBytes,
  }) async {
    if (fileName != null && fileBytes != null) {
      final fields = <String, String>{
        'submission_format': 'file',
        if (deliverableUrl != null && deliverableUrl.trim().isNotEmpty)
          'deliverable_url': deliverableUrl.trim(),
        if (submissionNotes != null && submissionNotes.trim().isNotEmpty)
          'submission_notes': submissionNotes.trim(),
      };
      for (var i = 0; i < attachmentLinks.length; i++) {
        fields['attachment_links[$i]'] = attachmentLinks[i];
      }
      return (await _client.postMultipart(
            '/milestones/$milestoneId/submissions',
            fields: fields,
            fileField: 'deliverable_file',
            fileName: fileName,
            fileBytes: fileBytes,
          ))['data']
          as Map<String, dynamic>;
    }
    return (await _client.post(
          '/milestones/$milestoneId/submissions',
          body: {
            'submission_format': submissionFormat,
            if (deliverableUrl != null && deliverableUrl.trim().isNotEmpty)
              'deliverable_url': deliverableUrl.trim(),
            if (submissionNotes != null && submissionNotes.trim().isNotEmpty)
              'submission_notes': submissionNotes.trim(),
            if (attachmentLinks.isNotEmpty) 'attachment_links': attachmentLinks,
          },
        ))['data']
        as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> messages(int projectId) async =>
      (await _client.get('/projects/$projectId/messages'))['data']
          as Map<String, dynamic>;

  Future<Map<String, dynamic>> sendMessage(
    int projectId, {
    String? message,
    String? fileName,
    Uint8List? fileBytes,
    int? milestoneId,
  }) async {
    if (fileName != null && fileBytes != null) {
      return (await _client.postMultipart(
            '/projects/$projectId/messages',
            fields: {
              if (message != null && message.trim().isNotEmpty)
                'message': message.trim(),
              if (milestoneId != null) 'milestone_id': '$milestoneId',
            },
            fileField: 'attachment_file',
            fileName: fileName,
            fileBytes: fileBytes,
          ))['data']
          as Map<String, dynamic>;
    }
    return (await _client.post(
          '/projects/$projectId/messages',
          body: {
            if (message != null && message.trim().isNotEmpty)
              'message': message.trim(),
            'milestone_id': ?milestoneId,
          },
        ))['data']
        as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> inbox({String? query}) async {
    final rows = (await _client.get(
      '/inbox',
      query: {if (query != null && query.trim().isNotEmpty) 'q': query.trim()},
    ))['data'];
    if (rows is! List) return const [];
    return rows.whereType<Map<String, dynamic>>().toList(growable: false);
  }

  Future<Map<String, dynamic>> fileDispute({
    required String referenceType,
    required int referenceId,
    required String category,
    required String description,
  }) async =>
      (await _client.post(
            '/disputes',
            body: {
              'reference_type': referenceType,
              'reference_id': referenceId,
              'category': category,
              'description': description.trim(),
            },
          ))['data']
          as Map<String, dynamic>;
}
