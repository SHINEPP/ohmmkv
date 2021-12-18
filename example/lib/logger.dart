import 'package:logger/logger.dart';

class Slog {
  Slog._internal();

  static final _logger = Logger(printer: PrettyPrinter());

  static void d(String message) {
    _logger.d(message);
  }

  static void e(String message) {
    _logger.e(message);
  }
}
