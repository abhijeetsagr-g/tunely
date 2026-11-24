import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/settings/cubit/customization_cubit.dart';
import 'package:tunely/features/settings/model/font_model.dart';
import 'package:tunely/features/settings/widgets/settings_card.dart';

class FontFamilySelector extends StatelessWidget {
  const FontFamilySelector({super.key});

  static const _fonts = FontModel.values;

  @override
  Widget build(BuildContext context) {
    final selected = context.select<CustomizationCubit, FontModel>(
      (c) => c.state.fontModel,
    );
    final cubit = context.read<CustomizationCubit>();

    return SettingsCard(
      title: 'Font family',
      child: Row(
        children: [
          for (var i = 0; i < _fonts.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(
              child: _FontCard(
                font: _fonts[i],
                selected: selected == _fonts[i],
                onTap: () => cubit.setFontFamily(_fonts[i]),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FontCard extends StatelessWidget {
  const _FontCard({
    required this.font,
    required this.selected,
    required this.onTap,
  });

  final FontModel font;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fg = selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant;
    const radius = BorderRadius.all(Radius.circular(16));

    return Semantics(
      button: true,
      selected: selected,
      label: '${font.label} font',
      excludeSemantics: true,
      child: Material(
        animationDuration: const Duration(milliseconds: 200),
        color: selected
            ? scheme.primaryContainer
            : scheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: selected ? scheme.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Text(
                  'Aa',
                  style: TextStyle(
                    fontFamily: font.family,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                    color: fg,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  font.label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontFamily: font.family,
                    color: fg,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
