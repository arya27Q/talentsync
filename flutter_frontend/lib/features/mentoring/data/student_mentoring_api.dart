import 'dart:typed_data';

import 'package:flutter_frontend/core/network/api_client.dart';

class StudentMentoringApi {
  StudentMentoringApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  static final StudentMentoringApi instance = StudentMentoringApi();
  final ApiClient _client;

  Future<Map<String, dynamic>> mentors({
    String? search,
    String? category,
    String? sort,
    int page = 1,
  }) async =>
      _client.get(
        '/mentoring/mentors',
        query: {
          'page': '$page',
          if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
          if (category != null && category.trim().isNotEmpty && category != 'Semua')
            'category': category.trim(),
          if (sort != null && sort.trim().isNotEmpty) 'sort': sort.trim(),
        },
      );

  Future<Map<String, dynamic>> mentorDetail(int mentorId) async =>
      (await _client.get('/mentoring/mentors/$mentorId'))['data']
          as Map<String, dynamic>;

  Future<bool> toggleMentorBookmark(int mentorId) async {
    final res = await _client.post('/mentoring/mentors/$mentorId/bookmark');
    return (res['data'] as Map<String, dynamic>)['is_bookmarked'] == true;
  }

  Future<Map<String, dynamic>> classDetail(int classId) async =>
      (await _client.get('/mentoring/classes/$classId'))['data']
          as Map<String, dynamic>;

  Future<Map<String, dynamic>> bookClass(
    int classId, {
    String? topicFocus,
    String? studentNotes,
    String? materialsUrl,
  }) async =>
      (await _client.post(
            '/mentoring/classes/$classId/book',
            body: {
              if (topicFocus != null && topicFocus.trim().isNotEmpty)
                'topic_focus': topicFocus.trim(),
              if (studentNotes != null && studentNotes.trim().isNotEmpty)
                'student_notes': studentNotes.trim(),
              if (materialsUrl != null && materialsUrl.trim().isNotEmpty)
                'materials_url': materialsUrl.trim(),
            },
          ))['data']
          as Map<String, dynamic>;

  Future<Map<String, dynamic>> studentMentors() async =>
      (await _client.get('/mentoring/student/mentors'))['data']
          as Map<String, dynamic>;

  Future<List<Map<String, dynamic>>> myEnrollments({int page = 1}) async => _list(
    (await _client.get(
      '/mentoring/enrollments/mine',
      query: {'page': '$page'},
    ))['data'],
  );

  Future<Map<String, dynamic>> enrollmentDetail(int enrollmentId) async =>
      (await _client.get('/mentoring/enrollments/$enrollmentId'))['data']
          as Map<String, dynamic>;

  Future<List<Map<String, dynamic>>> materials(int enrollmentId) async => _list(
    (await _client.get('/mentoring/enrollments/$enrollmentId/materials'))['data'],
  );

  Future<List<Map<String, dynamic>>> assignments(int enrollmentId) async => _list(
    (await _client.get(
      '/mentoring/enrollments/$enrollmentId/assignments',
    ))['data'],
  );

  Future<Map<String, dynamic>> submitAssignment(
    int assignmentId, {
    String? deliverableUrl,
    String? submissionNotes,
  }) async =>
      (await _client.post(
            '/mentoring/assignments/$assignmentId/submissions',
            body: {
              if (deliverableUrl != null && deliverableUrl.trim().isNotEmpty)
                'deliverable_url': deliverableUrl.trim(),
              if (submissionNotes != null && submissionNotes.trim().isNotEmpty)
                'submission_notes': submissionNotes.trim(),
            },
          ))['data']
          as Map<String, dynamic>;

  Future<Map<String, dynamic>> toggleActionItem(
    int enrollmentId,
    int itemId,
  ) async =>
      (await _client.patch(
            '/mentoring/enrollments/$enrollmentId/action-items/$itemId',
          ))['data']
          as Map<String, dynamic>;

  Future<List<Map<String, dynamic>>> messages(int enrollmentId) async => _list(
    (await _client.get(
      '/mentoring/enrollments/$enrollmentId/messages',
    ))['data'],
  );

  Future<Map<String, dynamic>> sendMessage(
    int enrollmentId, {
    String? message,
    String? attachmentUrl,
    String? fileName,
    Uint8List? fileBytes,
  }) async {
    if (fileName != null && fileBytes != null) {
      return (await _client.postMultipart(
            '/mentoring/enrollments/$enrollmentId/messages',
            fields: {
              if (message != null && message.trim().isNotEmpty)
                'message': message.trim(),
            },
            fileField: 'attachment_file',
            fileName: fileName,
            fileBytes: fileBytes,
          ))['data']
          as Map<String, dynamic>;
    }
    return (await _client.post(
          '/mentoring/enrollments/$enrollmentId/messages',
          body: {
            if (message != null && message.trim().isNotEmpty)
              'message': message.trim(),
            if (attachmentUrl != null && attachmentUrl.trim().isNotEmpty)
              'attachment_url': attachmentUrl.trim(),
          },
        ))['data']
        as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> confirmCompletion(
    int enrollmentId, {
    required int rating,
    String? reviewText,
    List<String>? strengthTags,
  }) async =>
      (await _client.post(
            '/mentoring/enrollments/$enrollmentId/confirm-completion',
            body: {
              'rating': rating,
              if (reviewText != null && reviewText.trim().isNotEmpty)
                'review_text': reviewText.trim(),
              if (strengthTags != null && strengthTags.isNotEmpty)
                'strength_tags': strengthTags,
            },
          ))['data']
          as Map<String, dynamic>;

  static List<Map<String, dynamic>> _list(dynamic value) {
    final rows = value is Map<String, dynamic> ? value['data'] : value;
    if (rows is! List) return const [];
    return rows.whereType<Map<String, dynamic>>().toList(growable: false);
  }
}

