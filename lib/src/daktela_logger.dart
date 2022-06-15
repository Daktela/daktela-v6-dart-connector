enum DaktelaLogLevel { off, minimal, verbose }

class DaktelaLogger {
  final Function(String message, {Object? error, StackTrace? stackTrace, DaktelaLogLevel? logLevel}) callback;
  final DaktelaLogLevel level;

  DaktelaLogger({required this.callback, this.level = DaktelaLogLevel.minimal});

  void log(String message, {Object? error, StackTrace? stackTrace, DaktelaLogLevel? logLevel}) {
    if (logLevel != null && (logLevel == DaktelaLogLevel.off || Enum.compareByIndex(level, logLevel) < 0)) {
      return;
    }
    callback(message, error: error, stackTrace: stackTrace);
  }
}
