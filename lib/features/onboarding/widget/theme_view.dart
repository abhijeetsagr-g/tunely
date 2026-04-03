import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/onboarding/widget/theme_tile.dart';
import 'package:tunely/features/theme/theme_cubit.dart';
import 'package:tunely/features/theme/theme_state.dart';
import 'package:tunely/features/theme/view/widget/settings_accent_color.dart';
import 'package:tunely/features/theme/view/widget/settings_dynamic_theme_tile.dart';

class ThemeBoardingView extends StatefulWidget {
  final VoidCallback onDone;

  const ThemeBoardingView({super.key, required this.onDone});

  @override
  State<ThemeBoardingView> createState() => _ThemeViewState();
}

class _ThemeViewState extends State<ThemeBoardingView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Stack(
          children: [
            /// Background reacts to theme changes
            BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, state) {
                final bg = Theme.of(context).scaffoldBackgroundColor;
                return Positioned.fill(child: ColoredBox(color: bg));
              },
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),

                Text(
                  'Personalize your vibe',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose how Tunely looks and feels.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withAlpha(60),
                  ),
                ),

                const Spacer(),

                /// 🎨 Dynamic Theme Toggle
                BlocBuilder<ThemeCubit, ThemeState>(
                  builder: (context, state) {
                    final cubit = context.read<ThemeCubit>();
                    return SettingsDynamicThemeTile(
                      accent: state.accent,
                      initialEnabled: cubit.dynamicThemeEnabled,
                      onToggle: cubit.toggleDynamicTheme,
                    );
                  },
                ),

                const SizedBox(height: 12),

                /// 🌗 Theme Mode Toggle
                BlocBuilder<ThemeCubit, ThemeState>(
                  builder: (context, state) {
                    final cubit = context.read<ThemeCubit>();
                    return ThemeTile(
                      icon: Icons.dark_mode_rounded,
                      title: 'Theme Mode',
                      subtitle: state.mode.name.toUpperCase(),
                      onTap: cubit.toggleTheme,
                    );
                  },
                ),

                const SizedBox(height: 12),

                /// 🎨 Accent Color Picker
                BlocBuilder<ThemeCubit, ThemeState>(
                  builder: (context, state) {
                    final cubit = context.read<ThemeCubit>();
                    final dynamicEnabled = cubit.dynamicThemeEnabled;

                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: dynamicEnabled ? 0.4 : 1.0,
                      child: IgnorePointer(
                        ignoring: false,
                        child: SettingsAccentColorPicker(
                          accent: state.accent,
                          onSelect: (value) {
                            cubit.setAccent(value);
                          },
                          onReset: cubit.resetAccent,
                        ),
                      ),
                    );
                  },
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: widget.onDone,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Continue'),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
