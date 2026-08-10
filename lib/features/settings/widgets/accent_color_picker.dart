import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/config/app_color.dart';
import 'package:tunely/core/config/app_theme.dart';
import 'package:tunely/features/settings/cubit/customization_cubit.dart';

class AccentColorPicker extends StatelessWidget {
  const AccentColorPicker({super.key, this.isOnboard = false});
  final bool isOnboard;

  static const _colors = [
    AppColor.mauve,
    AppColor.red,
    AppColor.blue,
    AppColor.teal,
    AppColor.purple,
  ];

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<CustomizationCubit>();
    final selected = cubit.state.accentColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isOnboard) ...[
            Text('Accent Color', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              'Pick the color used for highlights across the app.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final color in _colors)
                _ColorDot(
                  color: color,
                  selected: color == selected,
                  onTap: () => cubit.setAccentColor(color),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: AnimatedContainer(
        duration: AppTheme.expandDuration,
        curve: AppTheme.enter,
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: selected
              ? Border.all(color: scheme.onSurface, width: 3)
              : Border.all(color: Colors.transparent, width: 3),
        ),
        child: Icon(
          Icons.check_rounded,
          color: selected
              ? color.computeLuminance() > 0.5
                    ? Colors.black87
                    : Colors.white
              : Colors.transparent,
        ),
      ),
    );
  }
}
