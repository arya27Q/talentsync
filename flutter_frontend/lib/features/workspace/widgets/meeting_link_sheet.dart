import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class ParsedMeetingMessage {
  const ParsedMeetingMessage({
    required this.platform,
    required this.url,
    required this.note,
  });

  final String platform;
  final String url;
  final String note;
}

class MeetingLinkResult {
  const MeetingLinkResult({
    required this.platform,
    required this.url,
    required this.note,
  });

  final String platform;
  final String url;
  final String note;

  String toChatMessage() {
    final cleanNote = note.trim();
    final header = cleanNote.isEmpty
        ? 'Undangan $platform'
        : 'Undangan $platform: $cleanNote';
    return '$header\n$url';
  }
}

class MeetingLinkHelper {
  static final RegExp _urlRegex = RegExp(
    r'((?:https?:\/\/)?(?:meet\.google\.com|[\w-]+\.zoom\.us|zoom\.us|teams\.microsoft\.com|meet\.jit\.si)\/[^\s]+)',
    caseSensitive: false,
  );

  static final RegExp _anyHttpsRegex = RegExp(
    r'(https?:\/\/[^\s]+)',
    caseSensitive: false,
  );

  static String normalizeUrl(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return 'https://$trimmed';
  }

  static String detectPlatform(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('meet.google.com')) return 'Google Meet';
    if (lower.contains('zoom.us')) return 'Zoom';
    if (lower.contains('teams.microsoft.com')) return 'Microsoft Teams';
    if (lower.contains('meet.jit.si')) return 'Jitsi Meet';
    return 'Video Meeting';
  }

  /// Parses a chat message if it contains a Google Meet, Zoom, Teams, or Jitsi link,
  /// or if it was formatted by [MeetingLinkResult.toChatMessage].
  static ParsedMeetingMessage? parse(String? text) {
    if (text == null || text.trim().isEmpty) return null;

    final meetingMatch = _urlRegex.firstMatch(text);
    final isTaggedInvite = text.trimLeft().startsWith('Undangan ');
    final fallbackMatch = isTaggedInvite ? _anyHttpsRegex.firstMatch(text) : null;
    final match = meetingMatch ?? fallbackMatch;
    if (match == null) return null;

    final rawUrl = match.group(1) ?? '';
    final normalizedUrl = normalizeUrl(rawUrl);
    if (normalizedUrl.isEmpty) return null;

    final platform = detectPlatform(normalizedUrl);
    final remaining = text
        .replaceFirst(rawUrl, '')
        .replaceFirst(RegExp(r'^Undangan\s+[^:\n]+:?\s*'), '')
        .trim();

    return ParsedMeetingMessage(
      platform: platform,
      url: normalizedUrl,
      note: remaining,
    );
  }

  static Future<void> openMeetingUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(normalizeUrl(url));
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat membuka tautan meeting. Pastikan format link benar.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  static Future<MeetingLinkResult?> showSendSheet(
    BuildContext context, {
    required String partnerName,
  }) {
    return showModalBottomSheet<MeetingLinkResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _SendMeetingLinkSheet(partnerName: partnerName),
    );
  }

  static Widget buildMeetingCard(
    BuildContext context, {
    required ParsedMeetingMessage meeting,
    required bool isMe,
    String timeLabel = '',
  }) {
    final isZoom = meeting.platform == 'Zoom';
    final badgeBg = isMe
        ? Colors.white.withValues(alpha: 0.16)
        : (isZoom ? const Color(0xFFEFF6FF) : const Color(0xFFECFDF5));
    final badgeFg = isMe
        ? Colors.white
        : (isZoom ? AppColors.primaryNavy : const Color(0xFF15803D));

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: const BoxConstraints(maxWidth: 285),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primaryNavy : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
          border: isMe ? null : Border.all(color: AppColors.borderSlate),
          boxShadow: [
            BoxShadow(
              color: (isMe ? AppColors.primaryNavy : const Color(0xFF0F172A))
                  .withValues(alpha: isMe ? 0.18 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.videocam_rounded,
                    size: 18,
                    color: badgeFg,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Undangan ${meeting.platform}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: isMe ? Colors.white : AppColors.darkSlate,
                        ),
                      ),
                      Text(
                        'Ketuk tombol di bawah untuk bergabung',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: isMe
                              ? Colors.white.withValues(alpha: 0.78)
                              : AppColors.secondarySlate,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (meeting.note.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                meeting.note,
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.35,
                  color: isMe ? Colors.white : AppColors.darkSlate,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              meeting.url,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                color: isMe
                    ? const Color(0xFFBFDBFE)
                    : AppColors.primaryNavy,
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: isMe ? Colors.white : AppColors.primaryNavy,
                  foregroundColor: isMe ? AppColors.primaryNavy : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => openMeetingUrl(context, meeting.url),
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: Text(
                  'Gabung ${meeting.platform}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (timeLabel.isNotEmpty) ...[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  timeLabel,
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe
                        ? Colors.white.withValues(alpha: 0.72)
                        : AppColors.secondarySlate,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SendMeetingLinkSheet extends StatefulWidget {
  const _SendMeetingLinkSheet({required this.partnerName});

  final String partnerName;

  @override
  State<_SendMeetingLinkSheet> createState() => _SendMeetingLinkSheetState();
}

class _SendMeetingLinkSheetState extends State<_SendMeetingLinkSheet> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String _selectedPlatform = 'Google Meet';
  String? _validationError;

  @override
  void dispose() {
    _urlController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _openCreateRoom() async {
    final target = _selectedPlatform == 'Zoom'
        ? 'https://zoom.us/start/videomeeting'
        : 'https://meet.google.com/new';
    await MeetingLinkHelper.openMeetingUrl(context, target);
  }

  void _submit() {
    final raw = _urlController.text.trim();
    if (raw.isEmpty) {
      setState(() {
        _validationError = 'Tempel tautan Google Meet atau Zoom terlebih dahulu.';
      });
      return;
    }

    final normalized = MeetingLinkHelper.normalizeUrl(raw);
    final uri = Uri.tryParse(normalized);
    if (uri == null || !uri.hasAuthority || !uri.host.contains('.')) {
      setState(() {
        _validationError =
            'Format tautan tidak valid. Contoh: https://meet.google.com/abc-defg-hij';
      });
      return;
    }

    final detected = MeetingLinkHelper.detectPlatform(normalized);
    final platform = detected == 'Video Meeting' ? _selectedPlatform : detected;

    Navigator.pop(
      context,
      MeetingLinkResult(
        platform: platform,
        url: normalized,
        note: _noteController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderSlate,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.videocam_rounded,
                      color: AppColors.primaryNavy,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kirim Link Video Call',
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkSlate,
                          ),
                        ),
                        Text(
                          'Kirim tautan Google Meet / Zoom ke ${widget.partnerName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.secondarySlate,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Pilih Platform',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkSlate,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _platformChip('Google Meet'),
                  const SizedBox(width: 8),
                  _platformChip('Zoom'),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: OutlinedButton.icon(
                  onPressed: _openCreateRoom,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryNavy,
                    side: const BorderSide(color: AppColors.borderSlate),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: Text(
                    _selectedPlatform == 'Zoom'
                        ? 'Buat Room Zoom Baru'
                        : 'Buat Room Google Meet Baru',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _urlController,
                keyboardType: TextInputType.url,
                onChanged: (_) {
                  if (_validationError != null) {
                    setState(() => _validationError = null);
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Tautan Meeting',
                  hintText: _selectedPlatform == 'Zoom'
                      ? 'https://zoom.us/j/1234567890'
                      : 'https://meet.google.com/abc-defg-hij',
                  prefixIcon: const Icon(
                    Icons.link_rounded,
                    color: AppColors.primaryNavy,
                  ),
                  errorText: _validationError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Agenda / Catatan (Opsional)',
                  hintText: 'Contoh: Diskusi progres Tahap 1 pukul 19.00 WIB',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryNavy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _submit,
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text(
                    'Kirim Link Meeting ke Chat',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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

  Widget _platformChip(String label) {
    final selected = _selectedPlatform == label;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedPlatform = label),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryNavy : AppColors.canvasWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primaryNavy : AppColors.borderSlate,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: selected ? Colors.white : AppColors.darkSlate,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
