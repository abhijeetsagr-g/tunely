import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;

  const CircleButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 44,
    this.iconSize = 20,
  });

  bool get isEnabled => onTap != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isEnabled ? 1 : 0.5,
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
        shape: const CircleBorder(),
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: size,
            height: size,
            child: Center(
              child: Icon(
                icon,
                size: iconSize,
                color: isEnabled
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withAlpha(40),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
