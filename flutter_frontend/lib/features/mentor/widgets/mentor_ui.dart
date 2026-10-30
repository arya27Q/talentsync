import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';

class MentorCard extends StatelessWidget {
  const MentorCard({super.key, required this.child, this.padding = const EdgeInsets.all(18)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkBrown.withValues(alpha: .05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: child,
      );
}

class MentorPageHeader extends StatelessWidget {
  const MentorPageHeader({super.key, required this.title, this.subtitle, this.trailing});

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppColors.darkBrown, fontSize: 24, fontWeight: FontWeight.w800)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(subtitle!, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  ],
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      );
}

class MentorSectionTitle extends StatelessWidget {
  const MentorSectionTitle(this.title, {super.key, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Expanded(child: Text(title, style: const TextStyle(color: AppColors.darkBrown, fontSize: 17, fontWeight: FontWeight.w800))),
            if (action != null)
              TextButton(onPressed: onAction, child: Text(action!, style: const TextStyle(color: AppColors.tertiaryCaramel, fontWeight: FontWeight.w700))),
          ],
        ),
      );
}

class MentorAvatar extends StatelessWidget {
  const MentorAvatar({super.key, required this.initials, this.size = 48, this.color = const Color(0xFFE8D7C5)});

  final String initials;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => CircleAvatar(
        radius: size / 2,
        backgroundColor: color,
        child: Text(initials, style: TextStyle(color: AppColors.darkBrown, fontWeight: FontWeight.w800, fontSize: size * .28)),
      );
}

class MentorTag extends StatelessWidget {
  const MentorTag(this.label, {super.key, this.color = const Color(0xFFF5EFE8), this.textColor = AppColors.tertiaryCaramel});

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(30)),
        child: Text(label, style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.w700)),
      );
}
