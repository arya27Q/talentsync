import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';

class MentorCard extends StatelessWidget {
  const MentorCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: padding,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: AppColors.borderSlate),
    ),
    child: child,
  );
}

class MentorPageHeader extends StatelessWidget {
  const MentorPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

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
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.darkSlate,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    color: AppColors.secondarySlate,
                    fontSize: 13,
                  ),
                ),
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
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.darkSlate,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              action!,
              style: const TextStyle(
                color: AppColors.primaryNavy,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    ),
  );
}

class MentorAvatar extends StatelessWidget {
  const MentorAvatar({
    super.key,
    required this.initials,
    this.size = 48,
    this.color = AppColors.lightBlueSurface,
    this.textColor = AppColors.primaryNavy,
  });

  final String initials;
  final double size;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: size / 2,
    backgroundColor: color,
    child: Text(
      initials,
      style: TextStyle(
        color: textColor,
        fontWeight: FontWeight.w800,
        fontSize: size * .28,
      ),
    ),
  );
}

class MentorTag extends StatelessWidget {
  const MentorTag(
    this.label, {
    super.key,
    this.color = const Color(0xFFF5EFE8),
    this.textColor = AppColors.primaryNavy,
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(30),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: textColor,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class MentorBottomNav extends StatelessWidget {
  const MentorBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _items = [
    (Icons.home_rounded, Icons.home_outlined, 'Beranda'),
    (Icons.calendar_month_rounded, Icons.calendar_month_outlined, 'Booking'),
    (Icons.groups_rounded, Icons.groups_outlined, 'Murid'),
    (
      Icons.account_balance_wallet_rounded,
      Icons.account_balance_wallet_outlined,
      'Wallet',
    ),
    (Icons.person_rounded, Icons.person_outline_rounded, 'Profil'),
  ];

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: AppColors.borderSlate),
      ),
      child: Row(
        children: List.generate(_items.length, (index) {
          final selected = index == selectedIndex;
          final item = _items[index];
          return Expanded(
            flex: selected ? 2 : 1,
            child: Semantics(
              button: true,
              selected: selected,
              label: item.$3,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => onSelected(index),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 48),
                  padding: EdgeInsets.symmetric(
                    horizontal: selected ? 11 : 6,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primaryNavy
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        selected ? item.$1 : item.$2,
                        color: selected
                            ? Colors.white
                            : AppColors.secondarySlate,
                        size: 21,
                      ),
                      if (selected) ...[
                        const SizedBox(width: 6),
                        Flexible(
                          child: ExcludeSemantics(
                            child: Text(
                              item.$3,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    ),
  );
}
