import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/customization/cubit/customization_cubit.dart';

class ThemePickerWidget extends StatelessWidget {
  const ThemePickerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<CustomizationCubit>();
    final themeMode = cubit.state.themeMode;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: _ThemeCard(
                icon: Icons.light_mode_rounded,
                label: 'Light',
                selected: themeMode == ThemeMode.light,
                onTap: () => cubit.setThemeMode(ThemeMode.light),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ThemeCard(
                icon: Icons.settings_rounded,
                label: 'System',
                selected: themeMode == ThemeMode.system,
                onTap: () => cubit.setThemeMode(ThemeMode.system),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ThemeCard(
                icon: Icons.dark_mode_rounded,
                label: 'Dark',
                selected: themeMode == ThemeMode.dark,
                onTap: () => cubit.setThemeMode(ThemeMode.dark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: selected
          ? scheme.primaryContainer
          : scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: selected
                    ? scheme.onPrimaryContainer
                    : scheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(label, style: Theme.of(context).textTheme.labelMedium),
            ],
          ),
        ),
      ),
    );
  }
}
