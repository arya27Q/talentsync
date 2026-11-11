import 'package:flutter_frontend/core/network/api_client.dart';

class MentorApi {
  MentorApi._();

  static final MentorApi instance = MentorApi._();
  final ApiClient _client = ApiClient.instance;

  Future<Map<String, dynamic>> dashboard() async =>
      (await _client.get('/mentoring/mentor/dashboard'))['data']
          as Map<String, dynamic>;

  Future<Map<String, dynamic>> profile() async =>
      (await _client.get('/mentoring/mentor/profile'))['data']
          as Map<String, dynamic>;

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> body) async =>
      (await _client.put('/mentoring/mentor/profile', body: body))['data']
          as Map<String, dynamic>;

  Future<Map<String, dynamic>> walletSummary() async =>
      (await _client.get('/wallet/summary'))['data'] as Map<String, dynamic>;

  Future<List<Map<String, dynamic>>> enrollments({int page = 1}) async => _list(
    (await _client.get(
      '/mentoring/mentor/enrollments',
      query: {'page': '$page'},
    ))['data'],
  );

  Future<List<Map<String, dynamic>>> classes({int page = 1}) async => _list(
    (await _client.get(
      '/mentoring/mentor/classes',
      query: {'page': '$page'},
    ))['data'],
  );

  Future<Map<String, dynamic>> createClass(Map<String, dynamic> body) async =>
      (await _client.post('/mentoring/mentor/classes', body: body))['data']
          as Map<String, dynamic>;

  Future<Map<String, dynamic>> updateClass(
    int id,
    Map<String, dynamic> body,
  ) async =>
      (await _client.put('/mentoring/mentor/classes/$id', body: body))['data']
          as Map<String, dynamic>;

  Future<void> deleteClass(int id) async =>
      _client.delete('/mentoring/mentor/classes/$id');

  Future<void> decideBooking(int enrollmentId, String decision) async {
    await _client.patch(
      '/mentoring/enrollments/$enrollmentId/decision',
      body: {'decision': decision},
    );
  }

  Future<void> updateAttendance(int enrollmentId, String status) async {
    await _client.patch(
      '/mentoring/enrollments/$enrollmentId/attendance',
      body: {'status': status},
    );
  }

  Future<void> submitAssessment({
    required int enrollmentId,
    required int score,
    required String feedback,
  }) async {
    await _client.post(
      '/mentoring/enrollments/$enrollmentId/assessment',
      body: {'score': score, 'mentor_feedback': feedback},
    );
  }

  Future<void> endorse(int enrollmentId, String notes) async {
    await _client.post(
      '/mentoring/enrollments/$enrollmentId/endorse',
      body: {'endorsement_notes': notes},
    );
  }

  Future<Map<String, dynamic>> createAssignment(
    int classId,
    Map<String, dynamic> body,
  ) async =>
      (await _client.post(
            '/mentoring/mentor/classes/$classId/assignments',
            body: body,
          ))['data']
          as Map<String, dynamic>;

  Future<List<Map<String, dynamic>>> assignments(int enrollmentId) async =>
      _list(
        (await _client.get(
          '/mentoring/enrollments/$enrollmentId/assignments',
        ))['data'],
      );

  Future<void> reviewSubmission({
    required int submissionId,
    required int score,
    required String feedback,
    required String decision,
  }) async {
    await _client.patch(
      '/mentoring/submissions/$submissionId/review',
      body: {'score': score, 'feedback': feedback, 'decision': decision},
    );
  }

  Future<List<Map<String, dynamic>>> messages(
    int enrollmentId, {
    int page = 1,
  }) async {
    final response = await _client.get(
      '/mentoring/enrollments/$enrollmentId/messages',
      query: {'page': '$page'},
    );
    return _list(response['data']);
  }

  Future<Map<String, dynamic>> sendMessage({
    required int enrollmentId,
    String? message,
    String? attachmentUrl,
  }) async =>
      (await _client.post(
            '/mentoring/enrollments/$enrollmentId/messages',
            body: {
              if (message != null && message.trim().isNotEmpty)
                'message': message.trim(),
              if (attachmentUrl != null && attachmentUrl.trim().isNotEmpty)
                'attachment_url': attachmentUrl.trim(),
            },
          ))['data']
          as Map<String, dynamic>;

  Future<List<Map<String, dynamic>>> cashOutHistory({int page = 1}) async =>
      _list(
        (await _client.get(
          '/wallet/cash-outs',
          query: {'page': '$page'},
        ))['data'],
      );

  Future<Map<String, dynamic>> requestCashOut({
    required int amountTc,
    required String bankName,
    required String accountNumber,
    required String accountHolderName,
  }) async =>
      (await _client.post(
            '/wallet/cash-out',
            body: {
              'amount_tc': amountTc,
              'bank_name': bankName.trim(),
              'account_number': accountNumber.trim(),
              'account_holder_name': accountHolderName.trim(),
            },
          ))['data']
          as Map<String, dynamic>;

  Future<Map<String, dynamic>> requestPremium() async =>
      (await _client.post('/mentoring/mentor/premium-subscriptions'))['data']
          as Map<String, dynamic>;

  Future<List<Map<String, dynamic>>> premiumHistory({int page = 1}) async =>
      _list(
        (await _client.get(
          '/mentoring/mentor/premium-subscriptions',
          query: {'page': '$page'},
        ))['data'],
      );

  static List<Map<String, dynamic>> _list(dynamic value) {
    final rows = value is Map<String, dynamic> ? value['data'] : value;
    if (rows is! List) return const [];
    return rows.whereType<Map<String, dynamic>>().toList(growable: false);
  }
}
