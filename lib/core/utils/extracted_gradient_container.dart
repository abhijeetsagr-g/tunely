import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/customization/cubit/customization_cubit.dart';

class ExtractedGradientContainer extends StatefulWidget {
  const ExtractedGradientContainer({
    super.key,
    required this.songId,
    required this.child,
    this.borderRadius = 16,
    this.padding,
  });

  final int? songId;
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  @override
  State<ExtractedGradientContainer> createState() =>
      _ExtractedGradientContainerState();
}

class _ExtractedGradientContainerState
    extends State<ExtractedGradientContainer> {
  Color? _extractedColor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_extractedColor == null) _extract();
  }

  @override
  void didUpdateWidget(ExtractedGradientContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.songId != widget.songId) _extract();
  }

  Future<void> _extract() async {
    final brightness = Theme.of(context).brightness;
    final color = await context.read<CustomizationCubit>().extractColors(
      widget.songId,
      brightness: brightness,
    );
    if (mounted) setState(() => _extractedColor = color);
  }

  List<Color> get _gradientColors {
    final base = _extractedColor;
    if (base == null) {
      return [
        Theme.of(context).colorScheme.primaryContainer,
        Theme.of(context).colorScheme.secondaryContainer,
      ];
    }

    final hsl = HSLColor.fromColor(base);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final adjusted = hsl
        .withLightness(
          isDark
              ? hsl.lightness.clamp(0.2, 0.5)
              : hsl.lightness.clamp(0.3, 0.55),
        )
        .withSaturation(hsl.saturation.clamp(0.3, 0.9));

    final dark = adjusted
        .withLightness((adjusted.lightness - 0.18).clamp(0.0, 1.0))
        .withSaturation((adjusted.saturation - 0.1).clamp(0.0, 1.0))
        .toColor();

    return [adjusted.toColor(), dark];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      padding: widget.padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomRight, // less diagonal = softer transition
          colors: _gradientColors,
        ),
      ),
      child: widget.child,
    );
  }
}
