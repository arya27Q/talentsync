import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';

class MentorSkillCategory {
  const MentorSkillCategory({
    required this.id,
    required this.label,
    required this.icon,
    required this.hint,
    required this.defaultSkills,
  });

  final String id;
  final String label;
  final IconData icon;
  final String hint;
  final List<String> defaultSkills;
}

class MentorSkillPicker extends StatefulWidget {
  const MentorSkillPicker({
    super.key,
    required this.selectedSkills,
    required this.onChanged,
    this.minSelection = 0,
  });

  final Set<String> selectedSkills;
  final ValueChanged<Set<String>> onChanged;
  final int minSelection;

  static const List<MentorSkillCategory> categories = [
    MentorSkillCategory(
      id: 'web',
      label: 'Web Programming',
      icon: Icons.language_rounded,
      hint: 'Ketik bahasa/tech web (misal: Go, Django, Express)',
      defaultSkills: [
        'Laravel',
        'React',
        'Next.js',
        'Node.js',
        'Vue',
        'PHP',
        'Tailwind CSS',
        'PostgreSQL',
      ],
    ),
    MentorSkillCategory(
      id: 'app',
      label: 'App Development',
      icon: Icons.phone_android_rounded,
      hint: 'Ketik tech mobile (misal: Kotlin, Swift, BLoC)',
      defaultSkills: [
        'Flutter',
        'Dart',
        'React Native',
        'Android Kotlin',
        'iOS Swift',
        'Firebase',
        'REST API',
      ],
    ),
    MentorSkillCategory(
      id: 'ai',
      label: 'AI Engineering',
      icon: Icons.psychology_alt_rounded,
      hint: 'Ketik topik AI/ML (misal: PyTorch, RAG, OpenCV)',
      defaultSkills: [
        'Python',
        'Machine Learning',
        'LLM & Prompting',
        'Data Science',
        'Computer Vision',
        'NLP',
      ],
    ),
    MentorSkillCategory(
      id: 'design',
      label: 'UI/UX & Desain',
      icon: Icons.palette_rounded,
      hint: 'Ketik tools/desain (misal: Framer, CorelDRAW)',
      defaultSkills: [
        'UI/UX Design',
        'Figma',
        'Desain Grafis',
        'Desain Kemasan',
        'Canva',
        'Branding UMKM',
      ],
    ),
    MentorSkillCategory(
      id: 'marketing',
      label: 'Digital Marketing',
      icon: Icons.campaign_rounded,
      hint: 'Ketik kanal/skill (misal: Shopee Ads, CRM)',
      defaultSkills: [
        'Digital Marketing',
        'Meta Ads',
        'TikTok Shop',
        'SEO',
        'Copywriting',
        'Social Media',
      ],
    ),
    MentorSkillCategory(
      id: 'media',
      label: 'Konten & Video',
      icon: Icons.movie_creation_rounded,
      hint: 'Ketik skill konten (misal: After Effects, Script)',
      defaultSkills: [
        'Video Editing',
        'CapCut',
        'Premiere Pro',
        'Fotografi Produk',
        'Reels & Short Video',
      ],
    ),
    MentorSkillCategory(
      id: 'business',
      label: 'Bisnis & Keuangan',
      icon: Icons.account_balance_wallet_rounded,
      hint: 'Ketik topik bisnis (misal: HPP, Pajak, POS)',
      defaultSkills: [
        'Akuntansi UMKM',
        'Excel Pembukuan',
        'Business Plan',
        'Manajemen Operasional',
        'Product Management',
      ],
    ),
    MentorSkillCategory(
      id: 'career',
      label: 'Karier & Portofolio',
      icon: Icons.work_outline_rounded,
      hint: 'Ketik topik karier (misal: Pitch Deck, GitHub)',
      defaultSkills: [
        'Portofolio',
        'Review CV',
        'Interview',
        'LinkedIn',
        'Presentasi Klien',
      ],
    ),
    MentorSkillCategory(
      id: 'other',
      label: 'Bidang Lainnya',
      icon: Icons.extension_rounded,
      hint: 'Ketik bidang/keahlian lain (misal: IoT, Bahasa Jepang)',
      defaultSkills: [],
    ),
  ];

  static List<String> get filterLabels => [
    'Semua',
    ...categories.where((c) => c.id != 'other').map((c) => c.label),
  ];

  static IconData iconForLabel(String label) {
    if (label == 'Semua') return Icons.grid_view_rounded;
    for (final cat in categories) {
      if (cat.label == label) return cat.icon;
    }
    return Icons.category_rounded;
  }

  @override
  State<MentorSkillPicker> createState() => _MentorSkillPickerState();
}

class _MentorSkillPickerState extends State<MentorSkillPicker> {
  static const Color _captionSlate = Color(0xFF475569);

  late String _activeCategoryId;
  final TextEditingController _customController = TextEditingController();
  late final Map<String, List<String>> _categoryCustomSkills;

  @override
  void initState() {
    super.initState();
    _categoryCustomSkills = {
      for (final cat in MentorSkillPicker.categories) cat.id: <String>[],
    };
    _activeCategoryId = _initialCategoryId();
    _syncUnknownSelectedIntoOther();
  }

  String _initialCategoryId() {
    for (final cat in MentorSkillPicker.categories) {
      if (cat.defaultSkills.any(widget.selectedSkills.contains)) {
        return cat.id;
      }
    }
    return MentorSkillPicker.categories.first.id;
  }

  void _syncUnknownSelectedIntoOther() {
    final allDefaults = MentorSkillPicker.categories
        .expand((cat) => cat.defaultSkills)
        .map((e) => e.toLowerCase())
        .toSet();
    for (final skill in widget.selectedSkills) {
      if (!allDefaults.contains(skill.toLowerCase()) &&
          !_categoryCustomSkills['other']!.contains(skill)) {
        _categoryCustomSkills['other']!.add(skill);
      }
    }
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  MentorSkillCategory get _activeCategory => MentorSkillPicker.categories
      .firstWhere((cat) => cat.id == _activeCategoryId);

  List<String> _skillsForCategory(MentorSkillCategory cat) => [
    ...cat.defaultSkills,
    ...?_categoryCustomSkills[cat.id],
  ];

  int _selectedCountForCategory(MentorSkillCategory cat) {
    final items = _skillsForCategory(cat);
    return items.where(widget.selectedSkills.contains).length;
  }

  void _toggleSkill(String skill) {
    final next = Set<String>.from(widget.selectedSkills);
    if (next.contains(skill)) {
      if (next.length <= widget.minSelection) return;
      next.remove(skill);
    } else {
      next.add(skill);
    }
    widget.onChanged(next);
  }

  void _addCustomSkill() {
    final raw = _customController.text.trim();
    if (raw.isEmpty) return;

    final allExisting = MentorSkillPicker.categories
        .expand(_skillsForCategory)
        .toList();
    final existing = allExisting.cast<String?>().firstWhere(
      (item) => item != null && item.toLowerCase() == raw.toLowerCase(),
      orElse: () => null,
    );

    final next = Set<String>.from(widget.selectedSkills);
    setState(() {
      if (existing != null) {
        next.add(existing);
      } else {
        _categoryCustomSkills[_activeCategoryId]!.add(raw);
        next.add(raw);
      }
      _customController.clear();
    });
    widget.onChanged(next);
  }

  void _removeCustomSkill(String categoryId, String skill) {
    final next = Set<String>.from(widget.selectedSkills);
    if (next.contains(skill) && next.length <= widget.minSelection) return;
    setState(() {
      _categoryCustomSkills[categoryId]?.remove(skill);
    });
    next.remove(skill);
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final activeCategory = _activeCategory;
    final activeSkills = _skillsForCategory(activeCategory);
    final customSet = (_categoryCustomSkills[activeCategory.id] ?? const [])
        .toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih kategori bidang',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: _captionSlate,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _activeCategoryId,
          isExpanded: true,
          dropdownColor: Colors.white,
          elevation: 6,
          menuMaxHeight: 380,
          borderRadius: BorderRadius.circular(16),
          icon: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.lightBlueSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.primaryNavy,
              size: 20,
            ),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.borderSlate),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.borderSlate),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.primaryNavy,
                width: 1.5,
              ),
            ),
          ),
          selectedItemBuilder: (context) => MentorSkillPicker.categories.map((
            cat,
          ) {
            final count = _selectedCountForCategory(cat);
            return Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.lightBlueSurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    cat.icon,
                    size: 16,
                    color: AppColors.primaryNavy,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    cat.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkSlate,
                    ),
                  ),
                ),
                if (count > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryNavy,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$count dipilih',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 6),
              ],
            );
          }).toList(),
          items: MentorSkillPicker.categories.map((cat) {
            final count = _selectedCountForCategory(cat);
            final isActive = cat.id == _activeCategoryId;
            final preview = cat.defaultSkills.isEmpty
                ? 'Ketik sendiri bidang atau keahlian khusus'
                : cat.defaultSkills.take(3).join(', ');
            return DropdownMenuItem<String>(
              value: cat.id,
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primaryNavy
                          : AppColors.lightBlueSurface,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(
                      cat.icon,
                      size: 17,
                      color: isActive ? Colors.white : AppColors.primaryNavy,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          cat.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isActive
                                ? AppColors.primaryNavy
                                : AppColors.darkSlate,
                          ),
                        ),
                        Text(
                          preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: _captionSlate,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (count > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlueSurface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _activeCategoryId = value);
          },
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.canvasWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderSlate),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    activeCategory.icon,
                    size: 15,
                    color: AppColors.primaryNavy,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      activeCategory.id == 'other'
                          ? 'Bidang kustom di luar kategori'
                          : 'Sub-keahlian · ${activeCategory.label}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkSlate,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (activeSkills.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Belum ada keahlian kustom. Ketik bidang atau teknologi Anda di bawah lalu tekan Tambah.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: _captionSlate,
                      height: 1.35,
                    ),
                  ),
                )
              else
                Wrap(
                  spacing: 6,
                  runSpacing: 2,
                  children: activeSkills.map((skill) {
                    final isSelected = widget.selectedSkills.contains(skill);
                    final isCustom = customSet.contains(skill);
                    final shape = RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primaryNavy
                            : AppColors.borderSlate,
                      ),
                    );
                    final labelStyle = TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.darkSlate,
                    );

                    if (isCustom) {
                      return InputChip(
                        label: Text(skill, style: labelStyle),
                        selected: isSelected,
                        showCheckmark: false,
                        selectedColor: AppColors.primaryNavy,
                        backgroundColor: Colors.white,
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        shape: shape,
                        deleteIcon: Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: isSelected ? Colors.white : _captionSlate,
                        ),
                        deleteButtonTooltipMessage: 'Hapus $skill',
                        onDeleted: () =>
                            _removeCustomSkill(activeCategory.id, skill),
                        onSelected: (_) => _toggleSkill(skill),
                      );
                    }

                    return FilterChip(
                      label: Text(skill, style: labelStyle),
                      selected: isSelected,
                      showCheckmark: false,
                      selectedColor: AppColors.primaryNavy,
                      backgroundColor: Colors.white,
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      shape: shape,
                      onSelected: (_) => _toggleSkill(skill),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _customController,
                      textInputAction: TextInputAction.done,
                      inputFormatters: [LengthLimitingTextInputFormatter(32)],
                      onSubmitted: (_) => _addCustomSkill(),
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.darkSlate,
                      ),
                      decoration: InputDecoration(
                        hintText: activeCategory.hint,
                        hintStyle: const TextStyle(
                          fontSize: 12,
                          color: _captionSlate,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.borderSlate,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.borderSlate,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primaryNavy,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: _addCustomSkill,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryNavy,
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: AppColors.primaryNavy),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text(
                        'Tambah',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (widget.selectedSkills.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            'Keahlian terpilih (${widget.selectedSkills.length})',
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: _captionSlate,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 2,
            children: widget.selectedSkills.map((skill) {
              final canRemove =
                  widget.selectedSkills.length > widget.minSelection;
              return InputChip(
                label: Text(
                  skill,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryNavy,
                  ),
                ),
                backgroundColor: AppColors.lightBlueSurface,
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.padded,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: AppColors.primaryNavy.withValues(alpha: 0.25),
                  ),
                ),
                deleteIcon: canRemove
                    ? const Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: AppColors.primaryNavy,
                      )
                    : null,
                deleteButtonTooltipMessage: canRemove
                    ? 'Hapus $skill dari pilihan'
                    : null,
                onDeleted: canRemove ? () => _toggleSkill(skill) : null,
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
