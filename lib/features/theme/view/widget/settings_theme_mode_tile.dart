import 'package:flutter/material.dart';
import 'package:tunely/features/theme/view/widget/settings_tile.dart';

class SettingsThemeModeTile extends StatelessWidget {
  final Color accent;
  final ThemeMode mode;
  final VoidCallback onToggle;

  const SettingsThemeModeTile({
    super.key,
    required this.accent,
    required this.mode,
    required this.onToggle,
  });

  IconData get _icon => switch (mode) {
    ThemeMode.dark => Icons.dark_mode_rounded,
    ThemeMode.light => Icons.light_mode_rounded,
    ThemeMode.system => Icons.brightness_auto_rounded,
  };

  String get _label => switch (mode) {
    ThemeMode.dark => 'Dark',
    ThemeMode.light => 'Light',
    ThemeMode.system => 'System',
  };

  String get _subtitle => switch (mode) {
    ThemeMode.dark => 'Always use dark theme',
    ThemeMode.light => 'Always use light theme',
    ThemeMode.system => 'Follow system preference',
  };

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      leading: Icon(_icon, color: accent, size: 22),
      title: 'Theme',
      subtitle: _subtitle,
      trailing: GestureDetector(
        onTap: onToggle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: accent.withAlpha(15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accent.withAlpha(40), width: 1),
          ),
          child: Text(
            _label,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
