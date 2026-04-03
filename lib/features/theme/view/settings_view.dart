import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/theme/theme_cubit.dart';
import 'package:tunely/features/theme/theme_state.dart';
import 'package:tunely/features/theme/view/widget/settings_about_card.dart';
import 'package:tunely/features/theme/view/widget/settings_accent_color.dart';
import 'package:tunely/features/theme/view/widget/settings_appbar.dart';
import 'package:tunely/features/theme/view/widget/settings_dynamic_theme_tile.dart';
import 'package:tunely/features/theme/view/widget/settings_section_header.dart';
import 'package:tunely/features/theme/view/widget/settings_theme_mode_tile.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final cubit = context.read<ThemeCubit>();
        final accent = state.accent;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: CustomScrollView(
            slivers: [
              SettingsAppBar(accent: accent),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SettingsSectionHeader(label: 'Appearance'),
                    SettingsThemeModeTile(
                      accent: accent,
                      mode: state.mode,
                      onToggle: cubit.toggleTheme,
                    ),
                    const SizedBox(height: 8),
                    SettingsDynamicThemeTile(
                      accent: accent,
                      initialEnabled: cubit.dynamicThemeEnabled,
                      onToggle: cubit.toggleDynamicTheme,
                    ),
                    const SizedBox(height: 24),
                    const SettingsSectionHeader(label: 'Accent Color'),
                    SettingsAccentColorPicker(
                      accent: accent,
                      onSelect: cubit.setAccent,
                      onReset: cubit.resetAccent,
                    ),
                    const SizedBox(height: 24),
                    const SettingsSectionHeader(label: 'About'),
                    SettingsAboutCard(accent: accent),
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
