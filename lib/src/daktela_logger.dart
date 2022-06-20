import 'package:daktela_connector/daktela_connector.dart';

/// Enumerator defining logger verbosity
enum DaktelaLogLevel { off, minimal, verbose }

/// Configuration of [DaktelaLogger] used in [DaktelaConnector]
/// [callback] is a method that is called during processing HTTP requests. In all the cases it provides [message] and in more specific cases (such as errors) are [error] and [stackTrace] also provided. In this method you are allowed to set up custom logging strategy.
/// [level] defines logger verbosity.
class DaktelaLogger {
  final Function(String message, {Object? error, StackTrace? stackTrace}) callback;
  final DaktelaLogLevel level;

  DaktelaLogger({required this.callback, this.level = DaktelaLogLevel.minimal});

  void log(String message, {Object? error, StackTrace? stackTrace, DaktelaLogLevel? logLevel}) {
    if (logLevel != null && (logLevel == DaktelaLogLevel.off || Enum.compareByIndex(level, logLevel) < 0)) {
      return;
    }
    callback(message, error: error, stackTrace: stackTrace);
  }
}
