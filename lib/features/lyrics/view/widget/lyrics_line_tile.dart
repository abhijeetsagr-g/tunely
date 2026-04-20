import 'package:flutter/material.dart';
import 'package:tunely/features/lyrics/model/lyrics_line.dart';

class LyricsLineTile extends StatelessWidget {
  const LyricsLineTile({
    super.key,
    required this.line,
    required this.isActive,
    required this.isPast,
    this.onTap,
  });

  final LyricsLine line;
  final bool isActive;
  final bool isPast;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        style: TextStyle(
          fontSize: isActive ? 22 : 17,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
          color: isActive
              ? Colors.white
              : isPast
              ? Colors.white38
              : Colors.white60,
          height: 1.4,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: isActive ? 14 : 9,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                width: 3,
                height: isActive ? 28 : 0,
                margin: const EdgeInsets.only(right: 12, top: 2),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(child: Text(line.text)),
            ],
          ),
        ),
      ),
    );
  }
}
