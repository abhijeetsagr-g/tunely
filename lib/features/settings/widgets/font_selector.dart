import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/settings/cubit/customization_cubit.dart';
import 'package:tunely/features/settings/model/font_model.dart';

class FontFamilySelector extends StatelessWidget {
  const FontFamilySelector({super.key});

  static const List<FontModel> _fonts = [
    FontModel.system,
    FontModel.manrope,
    FontModel.inter,
  ];

  String _fontName(FontModel font) => switch (font) {
    FontModel.system => 'System',
    FontModel.manrope => 'Manrope',
    FontModel.inter => 'Inter',
  };

  String _fontDescription(FontModel font) => switch (font) {
    FontModel.system => 'Your device default font.',
    FontModel.manrope => 'Modern, geometric.',
    FontModel.inter => 'Clean, highly readable.',
  };

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<CustomizationCubit>();
    final selectedFont = cubit.state.fontModel;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Font family', style: theme.textTheme.titleLarge),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _fontName(selectedFont),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Choose the typography used throughout Tunely.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          SegmentedButton<FontModel>(
            segments: _fonts.map((font) {
              return ButtonSegment<FontModel>(
                value: font,
                label: Text(
                  'Aa',
                  style: TextStyle(
                    fontFamily: font.family,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                tooltip: _fontName(font),
              );
            }).toList(),
            selected: {selectedFont},
            showSelectedIcon: false,
            onSelectionChanged: (selection) {
              cubit.setFontFamily(selection.first);
            },
            style: SegmentedButton.styleFrom(
              visualDensity: VisualDensity.comfortable,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'The quick brown fox jumps over the lazy dog.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontFamily: selectedFont.family,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _fontDescription(selectedFont),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
