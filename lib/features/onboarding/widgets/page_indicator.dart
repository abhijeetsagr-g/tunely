import 'package:flutter/material.dart';

/// Animated dot indicator for the onboarding [PageView].
class OnboardingPageIndicator extends StatelessWidget {
  const OnboardingPageIndicator({
    super.key,
    required this.pageCount,
    required this.currentPage,
    required this.onDotTap,
  });

  final int pageCount;
  final int currentPage;
  final ValueChanged<int> onDotTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(pageCount, (index) {
          final selected = index == currentPage;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onDotTap(index),
            child: Padding(
              // bigger touch target without a bigger dot
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                width: selected ? 28 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: selected ? scheme.primary : scheme.outlineVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
