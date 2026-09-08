import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Controlled diagnostic logging.
///
/// Everything goes through here so that verbosity is decided in one place and
/// release builds stay quiet. Never pass user data that is not needed to
/// diagnose a problem.
abstract final class AppLogger {
  static const String _name = 'floor_is_lava';

  /// Development builds log freely; release builds log warnings and above.
  static bool get _verbose => kDebugMode;

  static void debug(String message) {
    if (!_verbose) return;
    developer.log(message, name: _name, level: 500);
  }

  static void info(String message) {
    if (!_verbose) return;
    developer.log(message, name: _name, level: 800);
  }

  static void warning(String message, [Object? error]) {
    developer.log(message, name: _name, level: 900, error: error);
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: _name,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
