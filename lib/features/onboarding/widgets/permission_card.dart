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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: granted
            ? scheme.primaryContainer.withValues(alpha: 0.6)
            : scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: granted
              ? scheme.primary.withValues(alpha: 0.5)
              : scheme.outlineVariant,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _IconBadge(granted: granted),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Music & audio',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Required to find songs on this device',
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: granted
                  ? _GrantedState(key: const ValueKey('granted'))
                  : _RequestButton(
                      key: const ValueKey('request'),
                      requesting: requesting,
                      onGrant: onGrant,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.granted});

  final bool granted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: granted
            ? scheme.primary
            : scheme.primary.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, anim) =>
            ScaleTransition(scale: anim, child: child),
        child: Icon(
          granted ? Icons.check_rounded : Icons.library_music_rounded,
          key: ValueKey(granted),
          color: granted ? scheme.onPrimary : scheme.primary,
        ),
      ),
    );
  }
}

class _GrantedState extends StatelessWidget {
  const _GrantedState({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.check_circle_rounded, size: 20, color: scheme.primary),
        const SizedBox(width: 8),
        Text(
          'Access granted',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: scheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }
}

class _RequestButton extends StatelessWidget {
  const _RequestButton({
    super.key,
    required this.requesting,
    required this.onGrant,
  });

  final bool requesting;
  final VoidCallback onGrant;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.tonalIcon(
        onPressed: requesting ? null : onGrant,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: requesting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.folder_open_rounded),
        label: Text(requesting ? 'Requesting…' : 'Allow access'),
      ),
    );
  }
}
