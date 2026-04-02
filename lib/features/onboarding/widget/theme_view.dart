import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/onboarding/widget/theme_tile.dart';
import 'package:tunely/features/theme/theme_cubit.dart';
import 'package:tunely/features/theme/theme_state.dart';

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

                    return ThemeTile(
                      icon: Icons.auto_awesome_rounded,
                      title: 'Dynamic Theme',
                      subtitle: 'Match colors with album artwork',
                      trailing: Switch(
                        value: cubit.dynamicThemeEnabled,
                        onChanged: (_) {
                          cubit.toggleDynamicTheme();
                          setState(() {}); // 👈 local rebuild if needed
                        },
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                BlocBuilder<ThemeCubit, ThemeState>(
                  builder: (context, state) {
                    final cubit = context.read<ThemeCubit>();

                    return ThemeTile(
                      icon: Icons.dark_mode_rounded,
                      title: 'Theme Mode',
                      subtitle: state.mode.name.toUpperCase(),
                      onTap: () {
                        cubit.toggleTheme();
                        setState(() {});
                      },
                    );
                  },
                ),

                const SizedBox(height: 12),

                BlocBuilder<ThemeCubit, ThemeState>(
                  builder: (context, state) {
                    final cubit = context.read<ThemeCubit>();

                    final disabled = cubit.dynamicThemeEnabled;

                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: disabled ? 0.4 : 1.0,
                      child: ThemeTile(
                        icon: Icons.palette_rounded,
                        title: 'Accent Color',
                        subtitle: disabled
                            ? 'Disabled while dynamic theme is on'
                            : 'Tap to change',
                        onTap: disabled
                            ? null
                            : () async {
                                final color = await _pickColor(
                                  context,
                                  state.accent,
                                );
                                if (color != null) {
                                  cubit.setAccent(color);
                                  setState(() {});
                                }
                              },
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

  /// 🎨 Color picker
  Future<Color?> _pickColor(BuildContext context, Color current) async {
    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.pink,
      Colors.orange,
      Colors.green,
      Colors.red,
      Colors.teal,
    ];

    return showModalBottomSheet<Color>(
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 12,
            children: colors.map((c) {
              return GestureDetector(
                onTap: () => Navigator.pop(context, c),
                child: CircleAvatar(
                  backgroundColor: c,
                  radius: 22,
                  child: current == c
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
