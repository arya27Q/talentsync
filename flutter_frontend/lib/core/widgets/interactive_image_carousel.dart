import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';

class CarouselSlideItem {
  final String imageUrl;
  final String tag;
  final Color tagColor;
  final String title;
  final String subtitle;
  final String? buttonText;
  final VoidCallback? onTap;

  const CarouselSlideItem({
    required this.imageUrl,
    required this.tag,
    this.tagColor = AppColors.primaryNavy,
    required this.title,
    required this.subtitle,
    this.buttonText,
    this.onTap,
  });
}

class InteractiveImageCarousel extends StatefulWidget {
  final List<CarouselSlideItem> items;
  final double height;
  final EdgeInsetsGeometry margin;

  const InteractiveImageCarousel({
    super.key,
    required this.items,
    this.height = 175,
    this.margin = const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
  });

  @override
  State<InteractiveImageCarousel> createState() =>
      _InteractiveImageCarouselState();
}

class _InteractiveImageCarouselState extends State<InteractiveImageCarousel> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      _pageController.animateToPage(
        widget.items.length - 1,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _goToNext() {
    if (_currentIndex < widget.items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: widget.margin,
      child: Container(
        height: widget.height,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkSlate.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Page View
              PageView.builder(
                controller: _pageController,
                itemCount: widget.items.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  return GestureDetector(
                    onTap: item.onTap,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background Photo
                        Image.network(
                          item.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: AppColors.primaryNavy,
                                child: const Center(
                                  child: Icon(
                                    Icons.image_rounded,
                                    color: Colors.white38,
                                    size: 40,
                                  ),
                                ),
                              ),
                        ),

                        // Contrast Gradient Overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.35),
                                Colors.black.withValues(alpha: 0.88),
                              ],
                            ),
                          ),
                        ),

                        // Content
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Top Row: Tag Pill & Slide Counter
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 9,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: item.tagColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      item.tag,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.4,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      '${index + 1}/${widget.items.length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Bottom Row: Text Information + Optional Action
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          item.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          item.subtitle,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Color(0xFFE2E8F0),
                                            fontSize: 11,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (item.buttonText != null) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentAmberGold,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        item.buttonText!,
                                        style: const TextStyle(
                                          color: AppColors.darkSlate,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Interactive Navigation Arrow Buttons (Left & Right)
              Positioned(
                right: 12,
                top: 48,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _NavButton(
                      icon: Icons.chevron_left_rounded,
                      onTap: _goToPrevious,
                      tooltip: 'Sebelumnya',
                    ),
                    const SizedBox(width: 6),
                    _NavButton(
                      icon: Icons.chevron_right_rounded,
                      onTap: _goToNext,
                      tooltip: 'Selanjutnya',
                    ),
                  ],
                ),
              ),

              // Bottom Center Dots Indicator
              Positioned(
                left: 16,
                bottom: 6,
                child: Row(
                  children: List.generate(
                    widget.items.length,
                    (dotIdx) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 4),
                      width: _currentIndex == dotIdx ? 16 : 5,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _currentIndex == dotIdx
                            ? AppColors.accentAmberGold
                            : Colors.white.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
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

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _NavButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.48),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.28),
              width: 1,
            ),
          ),
          child: Center(child: Icon(icon, size: 18, color: Colors.white)),
        ),
      ),
    );
  }
}
