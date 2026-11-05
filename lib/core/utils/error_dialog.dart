import 'package:flutter/material.dart';
import 'package:tunely/core/errors/app_error.dart';
import 'package:tunely/core/utils/app_navigator.dart';

/// Shows an error dialog with the exact captured error and a button that
/// reloads the whole app.
Future<void> showErrorDialog(
  BuildContext context, {
  required AppError error,
  String title = 'Something went wrong',
  bool allowDismiss = false,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: allowDismiss,
    builder: (dialogContext) {
      return PopScope(
        canPop: allowDismiss,
        child: AlertDialog(
          icon: const Icon(Icons.error_outline_rounded),
          title: Text(title),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(error.message),
                  const SizedBox(height: 12),
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: const EdgeInsets.only(top: 8),
                    title: const Text('Technical details'),
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SelectableText(error.technicalDetails),
                      ),
                      if (error.stackTrace != null) ...[
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: SelectableText(
                            error.stackTrace.toString(),
                            style: Theme.of(dialogContext).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            if (allowDismiss)
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Close'),
              ),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                reloadApp();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reload app'),
            ),
          ],
        ),
      );
    },
  );
}

/// Uses the root navigator, so it can be called from cubits, services, or
/// global error handlers. Does nothing if the app has not been mounted yet.
Future<void> showGlobalErrorDialog({
  required AppError error,
  String title = 'Something went wrong',
  bool allowDismiss = false,
}) {
  final context = rootNavigatorOverlayContext;
  if (context == null) return Future<void>.value();

  return showErrorDialog(
    context,
    error: error,
    title: title,
    allowDismiss: allowDismiss,
  );
}
