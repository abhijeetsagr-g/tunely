import 'package:flutter/material.dart';

class FieldWithInnerCounter extends StatelessWidget {
  const FieldWithInnerCounter({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    required this.maxLength,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final int maxLength;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      children: [
        TextField(
          controller: controller,
          textCapitalization: TextCapitalization.sentences,
          minLines: minLines,
          maxLines: maxLines,
          maxLength: maxLength,
          decoration: _fieldDecoration(context, hint: hint, icon: icon)
              .copyWith(
                counterText: '',
                contentPadding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 14,
                  bottom: 28, // room for the inner counter
                ),
              ),
        ),
        Positioned(
          right: 14,
          bottom: 8,
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              return Text(
                '${value.text.length}/$maxLength',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  InputDecoration _fieldDecoration(
    BuildContext context, {
    required String hint,
    IconData? icon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      prefixIcon: icon != null
          ? Icon(icon, size: 20, color: colorScheme.onSurfaceVariant)
          : null,
      prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 24),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
      ),
      labelStyle: theme.textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      hintStyle: theme.textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
    );
  }
}
