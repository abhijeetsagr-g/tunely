import 'package:flutter/material.dart';
import 'package:tunely/features/settings/widgets/settings_card.dart';

/// Slider card. Drags update the UI locally and only commit on release,
/// so the cubit/storage isn't written on every tick.
class SettingsSlider extends StatefulWidget {
  const SettingsSlider({
    super.key,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.format,
    required this.onCommit,
    this.minLabel,
    this.maxLabel,
    this.caption,
  });

  final String title;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String Function(double) format;
  final ValueChanged<double> onCommit;
  final String? minLabel;
  final String? maxLabel;
  final String? caption;

  @override
  State<SettingsSlider> createState() => _SettingsSliderState();
}

class _SettingsSliderState extends State<SettingsSlider> {
  double? _drag;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final current = (_drag ?? widget.value).clamp(widget.min, widget.max);
    final labelStyle = theme.textTheme.labelMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return SettingsCard(
      title: widget.title,
      trailing: Text(
        widget.format(current),
        style: theme.textTheme.titleMedium?.copyWith(
          color: scheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Slider(
            value: current,
            min: widget.min,
            max: widget.max,
            divisions: widget.divisions,
            label: widget.format(current),
            onChanged: (v) => setState(() => _drag = v),
            onChangeEnd: (v) {
              setState(() => _drag = null);
              widget.onCommit(v);
            },
          ),
          if (widget.minLabel != null || widget.maxLabel != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.minLabel ?? '', style: labelStyle),
                  Text(widget.maxLabel ?? '', style: labelStyle),
                ],
              ),
            ),
          if (widget.caption != null) ...[
            const SizedBox(height: 10),
            Text(
              widget.caption!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
