import 'package:flutter/material.dart';

class SectionHeader extends StatefulWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.onRefresh,
    this.buttonLabel,
    this.onButtonPressed,
  });

  final String title;
  final String? buttonLabel;
  final VoidCallback? onButtonPressed;
  final VoidCallback? onRefresh;

  @override
  State<SectionHeader> createState() => _SectionHeaderState();
}

class _SectionHeaderState extends State<SectionHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (widget.buttonLabel != null)
                TextButton.icon(
                  onPressed: widget.onButtonPressed,
                  icon: const Icon(Icons.shuffle),
                  label: Text(widget.buttonLabel!),
                ),
            ],
          ),
          if (widget.onRefresh != null)
            RotationTransition(
              turns: _controller,
              child: IconButton(
                onPressed: !mounted
                    ? null
                    : () {
                        _controller.forward(from: 0.0);
                        widget.onRefresh!();
                      },
                icon: const Icon(Icons.refresh),
              ),
            ),
        ],
      ),
    );
  }
}
