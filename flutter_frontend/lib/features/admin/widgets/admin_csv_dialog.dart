import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/features/admin/data/admin_api.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showAdminCsvExportDialog(
  BuildContext context, {
  required AdminApi api,
  required String resource,
  required String title,
  required void Function(String message, {bool isError}) onNotify,
}) async {
  try {
    final data = await api.exportCsv(resource);
    if (!context.mounted) return;
    final filename = (data['filename'] as String?) ?? 'talentsync_export.csv';
    final rowsCount = (data['rows_count'] as num?)?.toInt() ?? 0;
    final csv = (data['csv'] as String?) ?? '';

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(
              Icons.download_rounded,
              color: AppColors.primaryNavy,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Export CSV: $title',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Berkas: $filename ($rowsCount baris data)',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryNavy,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 180),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE6EDF6)),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    csv.isEmpty ? '(Tidak ada data)' : csv,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: AppColors.darkSlate,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
          OutlinedButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: csv));
              if (ctx.mounted) {
                onNotify('Isi CSV ($rowsCount baris) disalin ke clipboard.');
              }
            },
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('Salin CSV'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryNavy,
            ),
            onPressed: () async {
              final uri = Uri.dataFromString(
                csv,
                mimeType: 'text/csv',
                encoding: utf8,
              );
              await launchUrl(uri, mode: LaunchMode.externalApplication);
              if (ctx.mounted) {
                onNotify('Membuka berkas $filename...');
              }
            },
            icon: const Icon(Icons.file_download_rounded, size: 16),
            label: const Text('Unduh CSV'),
          ),
        ],
      ),
    );
  } on ApiException catch (e) {
    onNotify(e.message, isError: true);
  } catch (_) {
    onNotify('Gagal mengekspor laporan CSV.', isError: true);
  }
}
