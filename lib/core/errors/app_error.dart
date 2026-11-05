import 'package:flutter/foundation.dart';

/// A captured application error.
@immutable
class AppError {
  const AppError({
    required this.message,
    required this.details,
    this.origin,
    this.cause,
    this.stackTrace,
  });

  /// User-facing summary.
  final String message;

  /// Exact `error.toString()` captured at the throw/catch site.
  final String details;

  /// Where the error was caught, e.g. `LibraryCubit.initialLoad`.
  final String? origin;

  /// The original error object, kept for type information.
  final Object? cause;

  /// Stack trace captured alongside the error.
  final StackTrace? stackTrace;

  factory AppError.from(
    Object error,
    StackTrace stackTrace, {
    String? origin,
    String? userMessage,
  }) {
    return AppError(
      message: userMessage ?? _messageFor(error),
      details: _stringify(error),
      origin: origin,
      cause: error,
      stackTrace: stackTrace,
    );
  }

  /// Formatted text for the expandable "Technical details" section.
  String get technicalDetails {
    final buffer = StringBuffer();

    if (cause != null) {
      buffer.writeln('Type: ${cause.runtimeType}');
    }
    buffer.writeln('Error: $details');
    if (origin != null) {
      buffer.writeln('Where: $origin');
    }

    return buffer.toString().trim();
  }

  static String _messageFor(Object error) {
    final type = error.runtimeType.toString();

    if (type.contains('SocketException') ||
        type.contains('ClientException') ||
        type.contains('HandshakeException')) {
      return 'Could not connect. Check your network and try again.';
    }
    if (type.contains('TimeoutException')) {
      return 'The operation took too long to complete.';
    }
    if (type.contains('PlatformException')) {
      return 'A platform service failed.';
    }
    if (type.contains('HiveError')) {
      return 'Local storage could not be accessed.';
    }
    if (type.contains('FormatException')) {
      return 'Received invalid or corrupted data.';
    }

    return 'An unexpected error occurred.';
  }

  static String _stringify(Object error) {
    try {
      return error.toString();
    } catch (_) {
      return error.runtimeType.toString();
    }
  }
}
