import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PermissionPage extends StatefulWidget {
  const PermissionPage({super.key, required this.onGranted});
  final VoidCallback onGranted;
  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> {
  bool _granted = false;

  Future<void> _requestPermission() async {
    final query = OnAudioQuery();
    final granted = await query.permissionsRequest();
    if (granted) {
      setState(() => _granted = true);
      widget.onGranted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _granted ? Icons.check_circle_rounded : Icons.folder_rounded,
            size: 80,
            color: _granted
                ? Colors.green
                : Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 32),
          Text(
            _granted ? 'All set!' : 'One permission needed',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            _granted
                ? 'Tunely can now access your music library.'
                : 'To play your local music, Tunely needs access to your audio files. Nothing leaves your device.',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey, height: 1.8),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          if (!_granted)
            OutlinedButton.icon(
              onPressed: _requestPermission,
              icon: const Icon(Icons.folder_open_rounded),
              label: const Text('Grant Access'),
            ),
        ],
      ),
    );
  }
}
