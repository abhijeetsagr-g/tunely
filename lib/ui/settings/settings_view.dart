import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/config/app_colors.dart';
import 'package:tunely/logic/provider/theme/theme_cubit.dart';
import 'package:tunely/logic/provider/theme/theme_state.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          final cubit = context.read<ThemeCubit>();

          return Column(
            children: [
              /// Header (instead of AppBar)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      "Settings",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  children: [
                    /// Appearance Section
                    _sectionTitle("Appearance"),

                    SwitchListTile(
                      title: const Text("Dark Mode"),
                      value: state.mode == ThemeMode.dark,
                      onChanged: (_) => cubit.toggleTheme(),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Accent Color",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: AppColors.accents.map((color) {
                          final selected =
                              color.toARGB32() == state.accent.toARGB32();

                          return GestureDetector(
                            onTap: () => cubit.setAccent(color),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: selected
                                    ? Border.all(
                                        width: 3,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      )
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// About Section
                    _sectionTitle("About"),

                    const ListTile(
                      title: Text("App Version"),
                      trailing: Text("0.0.3"),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
