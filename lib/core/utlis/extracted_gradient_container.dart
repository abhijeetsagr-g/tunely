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
    return [base.withAlpha(200), base.withAlpha(100)];
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
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _gradientColors,
        ),
      ),
      child: widget.child,
    );
  }
}
