import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tunely/core/errors/app_error.dart';
import 'package:tunely/core/utils/app_navigator.dart';
import 'package:tunely/core/utils/error_dialog.dart';

bool _dialogVisible = false;
bool _dialogScheduled = false;

/// Installs app-wide handlers for errors that are not caught anywhere else.
///
/// Must be called after `WidgetsFlutterBinding.ensureInitialized()` and before
/// `runApp`.
void installGlobalErrorHandlers() {
  FlutterError.onError = (details) {
    // Keep Flutter's normal console output.
    FlutterError.presentError(details);

    if (!_shouldReport(details)) return;

    reportAppError(
      AppError.from(
        details.exception,
        details.stack ?? StackTrace.current,
        origin: _describe(details),
      ),
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught error: $error\n$stack');
    reportAppError(
      AppError.from(error, stack, origin: 'Unhandled async error'),
    );
    return true;
  };
}

/// Shows [error] in the global error dialog.
///
/// Only one dialog is shown at a time; errors that arrive while a dialog is
/// already visible are ignored.
void reportAppError(AppError error) {
  if (_dialogVisible || _dialogScheduled) return;

  _dialogScheduled = true;
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    _dialogScheduled = false;

    final context = rootNavigatorOverlayContext;
    if (context == null) return;

    _dialogVisible = true;
    try {
      await showErrorDialog(context, error: error);
    } catch (e, st) {
      debugPrint('Failed to show error dialog: $e\n$st');
    } finally {
      _dialogVisible = false;
    }
  });
  WidgetsBinding.instance.scheduleFrame();
}

bool _shouldReport(FlutterErrorDetails details) {
  if (details.silent) return false;

  // Layout overflows are noisy in debug and are not recoverable through a
  // restart; don't block the app with a modal for them.
  if (details.exceptionAsString().contains('overflowed')) return false;

  return true;
}

String? _describe(FlutterErrorDetails details) {
  final library = details.library;
  final context = details.context;

  if (library == null && context == null) return null;
  if (library == null) return context.toString();
  if (context == null) return library;
  return '$library — $context';
}
