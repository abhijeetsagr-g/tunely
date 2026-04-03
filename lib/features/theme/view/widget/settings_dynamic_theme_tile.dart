import 'package:flutter/material.dart';
import 'package:tunely/features/theme/view/widget/settings_tile.dart';

class SettingsDynamicThemeTile extends StatefulWidget {
  final Color accent;
  final bool initialEnabled;
  final Future<void> Function() onToggle;

  const SettingsDynamicThemeTile({
    super.key,
    required this.accent,
    required this.initialEnabled,
    required this.onToggle,
  });

  @override
  State<SettingsDynamicThemeTile> createState() =>
      _SettingsDynamicThemeTileState();
}

class _SettingsDynamicThemeTileState extends State<SettingsDynamicThemeTile> {
  late bool _enabled;

  @override
  void initState() {
    super.initState();
    _enabled = widget.initialEnabled;
  }

  Future<void> _handleToggle() async {
    setState(() => _enabled = !_enabled);
    await widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      leading: Icon(Icons.palette_outlined, color: widget.accent, size: 22),
      title: 'Dynamic Theme',
      subtitle: 'Pull accent color from album art',
      trailing: Switch.adaptive(
        value: _enabled,
        onChanged: (_) => _handleToggle(),
        activeThumbColor: widget.accent,
        activeTrackColor: widget.accent.withAlpha(30),
      ),
    );
  }
}
