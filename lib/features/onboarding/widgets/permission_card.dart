import 'package:flutter/material.dart';

class PermissionCard extends StatelessWidget {
  const PermissionCard({
    super.key,
    required this.requesting,
    required this.granted,
    required this.onGrant,
  });

  final bool requesting;
  final bool granted;
  final VoidCallback onGrant;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: granted
              ? _GrantedState(textTheme: textTheme)
              : _RequestState(
                  requesting: requesting,
                  scheme: scheme,
                  textTheme: textTheme,
                  onGrant: onGrant,
                ),
        ),
      ),
    );
  }
}

class _GrantedState extends StatelessWidget {
  const _GrantedState({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('granted'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF4CAF50),
          size: 44,
        ),
        const SizedBox(height: 12),
        Text(
          'Access granted',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _RequestState extends StatelessWidget {
  const _RequestState({
    required this.requesting,
    required this.scheme,
    required this.textTheme,
    required this.onGrant,
  });

  final bool requesting;
  final ColorScheme scheme;
  final TextTheme textTheme;
  final VoidCallback onGrant;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('request'),
      mainAxisSize: MainAxisSize.min,
      children: [
        FilledButton.tonalIcon(
          onPressed: requesting ? null : onGrant,
          icon: requesting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.folder_open_rounded),
          label: Text(requesting ? 'Requesting…' : 'Grant access to music'),
        ),
        const SizedBox(height: 12),
        Text(
          'Required to see your library',
          style: textTheme.labelMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
