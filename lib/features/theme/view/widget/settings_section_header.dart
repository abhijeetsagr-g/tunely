import 'package:flutter/material.dart';

class SettingsSectionHeader extends StatelessWidget {
  final String label;

  const SettingsSectionHeader({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10, left: 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.6,
          color: Theme.of(context).colorScheme.onSurface.withAlpha(45),
        ),
      ),
    );
  }
}
