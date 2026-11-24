import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/settings/cubit/customization_cubit.dart';
import 'package:tunely/features/settings/model/font_size_model.dart';
import 'package:tunely/features/settings/widgets/settings_card.dart';

class FontSizeSelector extends StatelessWidget {
  const FontSizeSelector({super.key});

  static const _sizes = [
    FontSizeModel.small,
    FontSizeModel.medium,
    FontSizeModel.large,
  ];

  @override
  Widget build(BuildContext context) {
    final selected = context.select<CustomizationCubit, FontSizeModel>(
      (c) => c.state.fontSizeModel,
    );
    final cubit = context.read<CustomizationCubit>();

    return SettingsCard(
      title: 'Font size',
      child: Column(
        children: [
          SegmentedButton<FontSizeModel>(
            expandedInsets: EdgeInsets.zero,
            showSelectedIcon: false,
            segments: [
              for (final size in _sizes)
                ButtonSegment(
                  value: size,
                  label: Text(
                    size.label,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
            ],
            selected: {selected},
            onSelectionChanged: (s) => cubit.setFontSize(s.first),
          ),
          const SizedBox(height: 12),
          SettingsPreview(
            child: Text(
              'With great power comes great bullshit.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
