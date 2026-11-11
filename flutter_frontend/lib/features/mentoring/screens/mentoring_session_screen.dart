import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_client.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/core/routes/student_route_args.dart';
import 'package:flutter_frontend/features/mentoring/data/student_mentoring_api.dart';
import 'package:url_launcher/url_launcher.dart';

class MentoringSessionScreen extends StatefulWidget {
  const MentoringSessionScreen({
    super.key,
    this.enrollmentId,
    this.mentoringApi,
  });

  final int? enrollmentId;
  final StudentMentoringApi? mentoringApi;

  @override
  State<MentoringSessionScreen> createState() => _MentoringSessionScreenState();
}

class _MentoringSessionScreenState extends State<MentoringSessionScreen> {
  late final StudentMentoringApi _api =
      widget.mentoringApi ?? StudentMentoringApi.instance;

  bool _isMicOn = true;
  bool _isVideoOn = true;
  final TextEditingController _noteController = TextEditingController();
  Timer? _elapsedTimer;
  int _elapsedSeconds = 0;

  bool _isLoading = true;
  bool _isSending = false;
  String? _error;
  int? _resolvedEnrollmentId;
  int? _currentUserId;
  Map<String, dynamic> _enrollment = const {};
  List<Map<String, dynamic>> _notes = const [];

  @override
  void initState() {
    super.initState();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedSeconds++);
    });
    _load();
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final user = await ApiClient.instance.readSessionUser();
      _currentUserId = (user?['id'] as num?)?.toInt();

      var targetId = widget.enrollmentId ?? _resolvedEnrollmentId;
      if (targetId == null) {
        final mine = await _api.myEnrollments();
        if (mine.isEmpty) {
          throw const ApiException('Belum ada sesi bimbingan yang dipesan.');
        }
        targetId = (mine.first['id'] as num).toInt();
      }
      final results = await Future.wait([
        _api.enrollmentDetail(targetId),
        _api.messages(targetId),
      ]);
      if (!mounted) return;
      setState(() {
        _resolvedEnrollmentId = targetId;
        _enrollment = results[0] as Map<String, dynamic>;
        _notes = (results[1] as List).whereType<Map<String, dynamic>>().toList();
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat ruang sesi mentoring.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sendNote() async {
    final enrollmentId = _resolvedEnrollmentId;
    final text = _noteController.text.trim();
    if (enrollmentId == null || text.isEmpty || _isSending) return;
    _noteController.clear();
    setState(() => _isSending = true);
    try {
      final sent = await _api.sendMessage(enrollmentId, message: text);
      if (!mounted) return;
      setState(() {
        _notes = [..._notes, sent];
      });
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _openMeet() async {
    final cls = (_enrollment['class'] as Map<String, dynamic>?) ?? const {};
    final link = (cls['meeting_link'] as String?) ?? '';
    if (link.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tautan pertemuan tersedia setelah mentor menerima booking sesi.',
          ),
        ),
      );
      return;
    }
    final uri = Uri.tryParse(link);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _formatDuration(int totalSeconds) {
    final mins = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final cls = (_enrollment['class'] as Map<String, dynamic>?) ?? const {};
    final mentorName = (cls['mentor_name'] as String?) ?? 'Mentor';

    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      appBar: AppBar(
        backgroundColor: AppColors.canvasWhite,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.keyboard_arrow_left_rounded,
            color: AppColors.darkSlate,
            size: 28,
          ),
        ),
        title: Text(
          'Bersama $mentorName',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.darkSlate,
            fontWeight: FontWeight.bold,
            fontSize: 16.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                _formatDuration(_elapsedSeconds),
                style: const TextStyle(
                  color: AppColors.primaryNavy,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error!),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: _load, child: const Text('Coba lagi')),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: Column(
                  children: [
                    // Virtual Room Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.darkSlate,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        children: [
                          Text(
                            (cls['topic'] as String?) ?? 'Sesi Mentoring',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Status: ${_enrollment['status'] ?? '-'} · ${_enrollment['paid_tc'] ?? 0} TC',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton.filled(
                                style: IconButton.styleFrom(
                                  backgroundColor: _isMicOn
                                      ? Colors.white24
                                      : const Color(0xFFDC2626),
                                ),
                                onPressed: () =>
                                    setState(() => _isMicOn = !_isMicOn),
                                icon: Icon(
                                  _isMicOn
                                      ? Icons.mic_rounded
                                      : Icons.mic_off_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              IconButton.filled(
                                style: IconButton.styleFrom(
                                  backgroundColor: _isVideoOn
                                      ? Colors.white24
                                      : const Color(0xFFDC2626),
                                ),
                                onPressed: () =>
                                    setState(() => _isVideoOn = !_isVideoOn),
                                icon: Icon(
                                  _isVideoOn
                                      ? Icons.videocam_rounded
                                      : Icons.videocam_off_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryNavy,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: _openMeet,
                                icon: const Icon(
                                  Icons.video_call_rounded,
                                  size: 18,
                                ),
                                label: const Text('Buka Meet'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.borderSlate),
                        ),
                        child: _notes.isEmpty
                            ? const Center(
                                child: Text(
                                  'Catatan & diskusi sesi akan tampil di sini.',
                                  style: TextStyle(
                                    color: AppColors.secondarySlate,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _notes.length,
                                itemBuilder: (_, i) {
                                  final n = _notes[i];
                                  final isMe =
                                      (n['sender_id'] as num?)?.toInt() ==
                                      _currentUserId;
                                  final senderName =
                                      (n['sender']?['name'] as String?) ??
                                      (isMe ? 'Anda' : mentorName);
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      '$senderName: ${n['message'] ?? n['attachment_url'] ?? ''}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.darkSlate,
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),

                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _noteController,
                            onSubmitted: (_) => _sendNote(),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Tulis catatan sesi...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primaryNavy,
                          ),
                          onPressed: _isSending ? null : _sendNote,
                          icon: const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.selesaiBimbingan,
                          arguments: MentoringEnrollmentArgs(
                            enrollmentId: _resolvedEnrollmentId,
                          ),
                        ),
                        child: const Text(
                          'Selesai & Evaluasi Bimbingan',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
