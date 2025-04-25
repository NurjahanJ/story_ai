import 'package:logger/logger.dart';

/// A utility class for logging messages throughout the app.
/// This replaces direct print statements with structured logging.
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  /// Log a debug message
  static void d(String message) {
    _logger.d(message);
  }

  /// Log an info message
  static void i(String message) {
    _logger.i(message);
  }

  /// Log a warning message
  static void w(String message) {
    _logger.w(message);
  }

  /// Log an error message
  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}
