import 'package:flutter/material.dart';
import 'package:tunely/features/playback/view/mini_player/mini_player_state.dart';

void popUpNotifer(BuildContext context, String message) {
  const double notificationHeight = 48.0;
  snackBarOffset.value += notificationHeight;

  final entry = OverlayEntry(
    builder: (context) => Positioned(
      left: 12,
      right: 12,
      bottom: 16,
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(4),
        color:
            Theme.of(context).snackBarTheme.backgroundColor ??
            const Color(0xFF323232),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            message,
            style:
                Theme.of(context).snackBarTheme.contentTextStyle ??
                const TextStyle(color: Colors.white),
          ),
        ),
      ),
    ),
  );

  Overlay.of(context).insert(entry);

  Future.delayed(const Duration(milliseconds: 700)).then((_) {
    entry.remove();
    snackBarOffset.value -= notificationHeight;
  });
}
