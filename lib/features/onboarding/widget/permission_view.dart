import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionView extends StatefulWidget {
  final VoidCallback onAllGranted;
  const PermissionView({super.key, required this.onAllGranted});

  @override
  State<PermissionView> createState() => _PermissionViewState();
}

class _PermissionViewState extends State<PermissionView> {
  final Map<String, Permission> _permissions = {
    'Audio Library': Permission.audio,
    'Notifications': Permission.notification,
  };

  final Map<String, IconData> _icons = {
    'Audio Library': Icons.library_music_rounded,
    'Notifications': Icons.notifications_rounded,
  };

  final Map<String, String> _descriptions = {
    'Audio Library': 'Access your local music files for playback',
    'Notifications': 'Show playback controls in the notification bar',
  };

  final Map<String, PermissionStatus> _statuses = {
    'Audio Library': PermissionStatus.denied,
    'Notifications': PermissionStatus.denied,
  };

  bool get _allGranted =>
      _statuses.values.every((s) => s.isGranted || s.isLimited);

  @override
  void initState() {
    super.initState();
    _checkExisting();
  }

  Future<void> _checkExisting() async {
    for (final entry in _permissions.entries) {
      final status = await entry.value.status;
      if (mounted) setState(() => _statuses[entry.key] = status);
    }
  }

  Future<void> _request(String key) async {
    final status = await _permissions[key]!.request();
    setState(() => _statuses[key] = status);
    if (_allGranted) widget.onAllGranted();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            Text(
              'Almost there',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tunely needs a few permissions to play your music.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withAlpha(60),
              ),
            ),
            const Spacer(),
            ..._statuses.keys.map((key) {
              final granted =
                  _statuses[key]!.isGranted || _statuses[key]!.isLimited;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: granted ? 0.4 : 1.0,
                  child: Material(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: granted ? null : () => _request(key),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: granted
                                    ? Colors.grey.withAlpha(20)
                                    : colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                granted ? Icons.check_rounded : _icons[key],
                                color: granted
                                    ? Colors.grey
                                    : colorScheme.primary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    key,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _descriptions[key]!,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onSurface.withAlpha(
                                        50,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: granted
                                  ? const SizedBox.shrink()
                                  : Text(
                                      'Enable',
                                      key: const ValueKey('enable'),
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                            color: colorScheme.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
            const Spacer(),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _allGranted ? 1.0 : 0.3,
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _allGranted ? widget.onAllGranted : null,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Continue'),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
