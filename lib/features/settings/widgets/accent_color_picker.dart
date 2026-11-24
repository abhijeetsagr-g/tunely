import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/config/app_color.dart';
import 'package:tunely/core/config/app_theme.dart';
import 'package:tunely/features/settings/cubit/customization_cubit.dart';
import 'package:tunely/features/settings/widgets/settings_card.dart';

class AccentColorPicker extends StatelessWidget {
  const AccentColorPicker({super.key, this.isOnboard = false});
  final bool isOnboard;

  static const _colors = [
    (AppColor.red, 'Red'),
    (AppColor.blue, 'Blue'),
    (AppColor.teal, 'Teal'),
    (AppColor.purple, 'Purple'),
  ];

  @override
  Widget build(BuildContext context) {
    final useDynamic = context.select<CustomizationCubit, bool>(
      (c) => c.state.useDynamic,
    );
    final selected = context.select<CustomizationCubit, Color>(
      (c) => c.state.accentColor,
    );
    final cubit = context.read<CustomizationCubit>();

    final dots = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DynamicColorBuilder(
          builder: (light, dark) {
            if (light == null) {
              const fallback = AppColor.mauve;
              return _ColorDot(
                color: fallback,
                label: 'Mauve',
                selected: !useDynamic && fallback == selected,
                onTap: () => cubit.setAccentColor(fallback),
              );
            }
            return _ColorDot(
              color: light.primary,
              label: 'Wallpaper colors',
              icon: Icons.wallpaper_rounded,
              selected: useDynamic,
              onTap: () => cubit.setUseDynamic(true),
            );
          },
        ),
        for (final (color, name) in _colors)
          _ColorDot(
            color: color,
            label: name,
            selected: !useDynamic && color == selected,
            onTap: () => cubit.setAccentColor(color),
          ),
      ],
    );

    if (isOnboard) return dots;
    return SettingsCard(title: 'Accent color', child: dots);
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final Color color;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final iconColor = color.computeLuminance() > 0.5
        ? Colors.black87
        : Colors.white;
    final iconData = selected ? Icons.check_rounded : icon;

    return Semantics(
      button: true,
      selected: selected,
      label: '$label accent color',
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: AppTheme.enterDuration,
        curve: AppTheme.enter,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? scheme.onSurface : Colors.transparent,
            width: 2,
          ),
        ),
        child: Material(
          color: color,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: 44,
              height: 44,
              child: iconData == null
                  ? null
                  : Icon(iconData, size: 22, color: iconColor),
            ),
          ),
        ),
      ),
    );
  }
}
