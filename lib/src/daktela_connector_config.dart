import 'package:daktela_connector/src/daktela_logger.dart';

class DaktelaConnectorConfig {
  final String url;
  final String accessToken;

  final Duration timeout;
  final Duration longPollingTimeout;

  final String userAgent;
  final bool cookieAuth;

  final DaktelaLogger? logger;
  final DaktelaErrorMessages? errors;

  DaktelaConnectorConfig({
    required this.url,
    this.accessToken = '',
    this.timeout = const Duration(seconds: 10),
    this.longPollingTimeout = const Duration(seconds: 10),
    this.userAgent = '',
    this.cookieAuth = false,
    this.logger,
    this.errors,
  });
}

class DaktelaErrorMessages {
  final String general;
  final String Function(String filename)? uploadFailed;
  final String timeout;
  final String unauthorized;
  final String notFound;

  DaktelaErrorMessages({
    this.general = 'Something went wrong',
    this.uploadFailed,
    this.timeout = 'Time limit exceeded',
    this.unauthorized = 'Invalid credentials',
    this.notFound = 'Page not found',
  });

  static set unauthorizedMessage(String message) {}

  String uploadFailedDefault(String filename) => 'Upload failed: $filename';
}
