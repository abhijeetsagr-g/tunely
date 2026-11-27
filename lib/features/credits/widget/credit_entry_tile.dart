import 'package:flutter/material.dart';
import 'package:tunely/core/config/app_theme.dart';
import 'package:tunely/features/credits/model/credit_entry.dart';

/// A single line of the credits roll.
///
/// Mirrors `LyricsLineTile`: the active row gets full contrast, a weight bump
/// and an accent bar, past rows fade out, future rows sit in between.
class CreditEntryTile extends StatelessWidget {
  const CreditEntryTile({
    super.key,
    required this.entry,
    required this.isActive,
    required this.isPast,
  });

  final CreditEntry entry;
  final bool isActive;
  final bool isPast;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onSurface = colorScheme.onSurface;

    final contentColor = isActive
        ? onSurface
        : isPast
        ? onSurface.withAlpha(60)
        : onSurface.withAlpha(120);

    return AnimatedContainer(
      duration: AppTheme.expandDuration,
      curve: AppTheme.enter,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          AnimatedContainer(
            duration: AppTheme.expandDuration,
            curve: AppTheme.enter,
            width: 3,
            height: isActive ? 34 : 0,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(child: _content(context, contentColor)),
        ],
      ),
    );
  }

  Widget _content(BuildContext context, Color contentColor) {
    final textTheme = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return switch (entry) {
      CreditTitle(:final title, :final subtitle) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedDefaultTextStyle(
            duration: AppTheme.expandDuration,
            curve: AppTheme.enter,
            style: TextStyle(
              fontSize: isActive ? 34 : 30,
              fontWeight: FontWeight.w800,
              letterSpacing: 8,
              height: 1.1,
              color: contentColor,
            ),
            child: Text(title),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: textTheme.labelSmall?.copyWith(
                letterSpacing: 2,
                color: muted,
              ),
            ),
          ],
        ],
      ),

      CreditSection(:final title) => AnimatedDefaultTextStyle(
        duration: AppTheme.expandDuration,
        curve: AppTheme.enter,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 4,
          color: isActive
              ? Theme.of(context).colorScheme.primary
              : contentColor,
        ),
        child: Text(title.toUpperCase()),
      ),

      CreditPerson(:final role, :final name) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            role.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              letterSpacing: 1.5,
              color: muted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          AnimatedDefaultTextStyle(
            duration: AppTheme.expandDuration,
            curve: AppTheme.enter,
            style: TextStyle(
              fontSize: isActive ? 24 : 21,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: contentColor,
            ),
            child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),

      CreditName(:final name) => AnimatedDefaultTextStyle(
        duration: AppTheme.expandDuration,
        curve: AppTheme.enter,
        style: TextStyle(
          fontSize: isActive ? 21 : 19,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          color: contentColor,
        ),
        child: Text(name),
      ),

      CreditNote(:final text) => Text(
        text,
        style: textTheme.bodySmall?.copyWith(
          color: muted,
          fontStyle: FontStyle.italic,
        ),
      ),

      CreditSpacer() => const SizedBox.shrink(),
    };
  }
}
