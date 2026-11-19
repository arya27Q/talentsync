import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';

enum AppStatusDialogType {
  success,
  error,
  warning,
  info,
}

/// Dialog umpan balik pop-up modern di tengah layar dengan latar putih bersih,
/// aksen status tegas (Hijau untuk sukses, Merah untuk gagal/validasi, Amber untuk info),
/// serta tombol aksi solid yang mematuhi standar desain anti-slop.
class AppStatusDialog extends StatelessWidget {
  const AppStatusDialog({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    this.primaryButtonText,
    this.onPrimaryPressed,
    this.secondaryButtonText,
    this.onSecondaryPressed,
    this.dismissible = true,
  });

  final AppStatusDialogType type;
  final String title;
  final String message;
  final String? primaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryPressed;
  final bool dismissible;

  static Future<bool?> showError(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'Mengerti',
    VoidCallback? onConfirm,
    bool barrierDismissible = true,
  }) =>
      show(
        context,
        type: AppStatusDialogType.error,
        title: title,
        message: message,
        primaryButtonText: buttonText,
        onPrimaryPressed: onConfirm,
        barrierDismissible: barrierDismissible,
      );

  static Future<bool?> showSuccess(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'Lanjutkan',
    VoidCallback? onConfirm,
    bool barrierDismissible = false,
  }) =>
      show(
        context,
        type: AppStatusDialogType.success,
        title: title,
        message: message,
        primaryButtonText: buttonText,
        onPrimaryPressed: onConfirm,
        barrierDismissible: barrierDismissible,
      );

  static Future<bool?> showWarning(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'Mengerti',
    VoidCallback? onConfirm,
    bool barrierDismissible = true,
  }) =>
      show(
        context,
        type: AppStatusDialogType.warning,
        title: title,
        message: message,
        primaryButtonText: buttonText,
        onPrimaryPressed: onConfirm,
        barrierDismissible: barrierDismissible,
      );

  static Future<bool?> show(
    BuildContext context, {
    required AppStatusDialogType type,
    required String title,
    required String message,
    String? primaryButtonText,
    VoidCallback? onPrimaryPressed,
    String? secondaryButtonText,
    VoidCallback? onSecondaryPressed,
    bool barrierDismissible = true,
  }) =>
      showDialog<bool>(
        context: context,
        barrierDismissible: barrierDismissible,
        barrierColor: const Color(0xFF0F172A).withValues(alpha: 0.55),
        builder: (ctx) => AppStatusDialog(
          type: type,
          title: title,
          message: message,
          primaryButtonText: primaryButtonText ??
              (type == AppStatusDialogType.success ? 'Lanjutkan' : 'Mengerti'),
          onPrimaryPressed: () {
            Navigator.of(ctx).pop(true);
            onPrimaryPressed?.call();
          },
          secondaryButtonText: secondaryButtonText,
          onSecondaryPressed: secondaryButtonText != null
              ? () {
                  Navigator.of(ctx).pop(false);
                  onSecondaryPressed?.call();
                }
              : null,
          dismissible: barrierDismissible,
        ),
      );

  Color get _accentColor {
    switch (type) {
      case AppStatusDialogType.success:
        return const Color(0xFF10B981); // Emerald Green
      case AppStatusDialogType.error:
        return const Color(0xFFEF4444); // Rose Red
      case AppStatusDialogType.warning:
        return const Color(0xFFF59E0B); // Warm Amber
      case AppStatusDialogType.info:
        return AppColors.primaryNavy; // Deep Navy
    }
  }

  Color get _badgeBgColor {
    switch (type) {
      case AppStatusDialogType.success:
        return const Color(0xFFECFDF5);
      case AppStatusDialogType.error:
        return const Color(0xFFFEF2F2);
      case AppStatusDialogType.warning:
        return const Color(0xFFFFFBEB);
      case AppStatusDialogType.info:
        return const Color(0xFFEFF6FF);
    }
  }

  Color get _badgeBorderColor {
    switch (type) {
      case AppStatusDialogType.success:
        return const Color(0xFFA7F3D0);
      case AppStatusDialogType.error:
        return const Color(0xFFFECACA);
      case AppStatusDialogType.warning:
        return const Color(0xFFFDE68A);
      case AppStatusDialogType.info:
        return const Color(0xFFBFDBFE);
    }
  }

  IconData get _iconData {
    switch (type) {
      case AppStatusDialogType.success:
        return Icons.check_circle_rounded;
      case AppStatusDialogType.error:
        return Icons.error_outline_rounded;
      case AppStatusDialogType.warning:
        return Icons.warning_amber_rounded;
      case AppStatusDialogType.info:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 380),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.borderSlate.withValues(alpha: 0.9),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.14),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Accent Strip
              Container(
                height: 5,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _accentColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Status Badge Icon
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: _badgeBgColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _badgeBorderColor,
                          width: 2.0,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          _iconData,
                          size: 38,
                          color: _accentColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Dialog Title
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkSlate,
                        letterSpacing: -0.3,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Message Body
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.normal,
                        color: AppColors.secondarySlate,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        if (secondaryButtonText != null) ...[
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: onSecondaryPressed,
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  height: 48,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.canvasWhite,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: AppColors.borderSlate,
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Text(
                                    secondaryButtonText!,
                                    style: const TextStyle(
                                      color: AppColors.secondarySlate,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: onPrimaryPressed,
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                height: 48,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: type == AppStatusDialogType.error
                                      ? const Color(0xFFEF4444)
                                      : (type == AppStatusDialogType.success
                                          ? const Color(0xFF10B981)
                                          : AppColors.primaryNavy),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (type == AppStatusDialogType.error
                                              ? const Color(0xFFEF4444)
                                              : (type == AppStatusDialogType.success
                                                  ? const Color(0xFF10B981)
                                                  : AppColors.primaryNavy))
                                          .withValues(alpha: 0.28),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  primaryButtonText ?? 'Mengerti',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
