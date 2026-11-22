import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/config/app_color.dart';
import 'package:tunely/core/config/app_theme.dart';
import 'package:tunely/features/settings/cubit/customization_cubit.dart';

class AccentColorPicker extends StatelessWidget {
  const AccentColorPicker({super.key, this.isOnboard = false});
  final bool isOnboard;

  static const _colors = [
    AppColor.red,
    AppColor.blue,
    AppColor.teal,
    AppColor.purple,
  ];

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<CustomizationCubit>();
    final useDynamic = cubit.state.useDynamic;
    final selected = cubit.state.accentColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isOnboard) ...[
            Text('Accent Color', style: Theme.of(context).textTheme.titleLarge),
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
              DynamicColorBuilder(
                builder: (light, dark) {
                  if (light == null) {
                    const fallbackColor = AppColor.mauve;
                    return _ColorDot(
                      color: fallbackColor,
                      selected: !useDynamic && fallbackColor == selected,
                      onTap: () => cubit.setAccentColor(fallbackColor),
                    );
                  }

                  return _ColorDot(
                    color: light.primary,
                    selected: useDynamic,
                    icon: Icons.wallpaper_rounded,
                    onTap: () => cubit.setUseDynamic(true),
                  );
                },
              ),
              for (final color in _colors)
                _ColorDot(
                  color: color,
                  selected: !useDynamic && color == selected,
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
    this.icon,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final iconColor = color.computeLuminance() > 0.5
        ? Colors.black87
        : Colors.white;

    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: AnimatedContainer(
        duration: AppTheme.expandDuration,
        curve: AppTheme.enter,
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? scheme.onSurface : Colors.transparent,
            width: 3,
          ),
        ),
        child: Icon(selected ? Icons.check_rounded : icon, color: iconColor),
      ),
    );
  }
}
