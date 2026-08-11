import 'package:flutter/material.dart';
import 'package:tunely/features/onboarding/model/onboarding_page_data.dart';
import 'package:tunely/features/onboarding/widgets/permission_card.dart';
import 'package:tunely/features/settings/widgets/accent_color_picker.dart';
import 'package:tunely/features/settings/widgets/theme_picker.dart';

class OnboardingPageContent extends StatelessWidget {
  const OnboardingPageContent({
    super.key,
    required this.page,
    required this.requestingPermission,
    required this.permissionGranted,
    required this.onGrantPermission,
  });

  final OnboardingPageData page;
  final bool requestingPermission;
  final bool permissionGranted;
  final VoidCallback onGrantPermission;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: _FadeSlideIn(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Artwork(page: page, scheme: scheme),
                    const SizedBox(height: 36),
                    _SubtitleBadge(
                      text: page.subtitle,
                      scheme: scheme,
                      textTheme: textTheme,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      page.title,
                      textAlign: TextAlign.center,
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                        height: 1.15,
                      ),
                    ),
                    if (page.body.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        page.body,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                    ],
                    if (page.isPermission) ...[
                      const SizedBox(height: 40),
                      PermissionCard(
                        requesting: requestingPermission,
                        granted: permissionGranted,
                        onGrant: onGrantPermission,
                      ),
                    ],
                    if (page.isTheme) ...[
                      const SizedBox(height: 28),
                      const ThemePicker(),
                      const SizedBox(height: 40),
                      const AccentColorPicker(isOnboard: true),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fades and slides its child up on first build — a lightweight entrance
/// animation with no extra dependencies.
class _FadeSlideIn extends StatelessWidget {
  const _FadeSlideIn({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 20),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

class _SubtitleBadge extends StatelessWidget {
  const _SubtitleBadge({
    required this.text,
    required this.scheme,
    required this.textTheme,
  });

  final String text;
  final ColorScheme scheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: textTheme.labelLarge?.copyWith(
          color: scheme.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _Artwork extends StatelessWidget {
  const _Artwork({required this.page, required this.scheme});

  final OnboardingPageData page;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 136,
      height: 136,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary.withValues(alpha: 0.35),
            scheme.primary.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.18),
            blurRadius: 32,
            spreadRadius: -4,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: page.imageAsset != null
          ? Padding(
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Image.asset(page.imageAsset!, fit: BoxFit.cover),
              ),
            )
          : Icon(page.icon, size: 60, color: scheme.primary),
    );
  }
}
