import 'package:daktela_connector/src/daktela_logger.dart';

/// Configuration used in [DaktelaConnector]
/// [url] - URL of Daktela instance
/// [accessToken] - user's access token used for authentication
/// [timeout] - request timeout
/// [longPollingTimeout] - in case you implement your custom app pull data worker, you are allowed to set long polling requests timeout
/// [userAgent] - your app user agent
/// [cookieAuth]` - allows you to authenticate request through cookies (default value is false and in that case access token will be added into request's query parameters)
/// [logger] - instance of [DaktelaLogger]
/// [errors] - instance of [DaktelaErrorMessages]
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

/// Customization of errors produced by [DaktelaConnector]
/// [general] - general error message
/// [timeout] - timeout error message
/// [unauthorized] - unauthorized error message
/// [notFound] - not found error message (when you are trying to reach not existing model)
class DaktelaErrorMessages {
  final String general;
  final String timeout;
  final String unauthorized;
  final String notFound;

  DaktelaErrorMessages({
    this.general = 'Something went wrong',
    this.timeout = 'Time limit exceeded',
    this.unauthorized = 'Invalid credentials',
    this.notFound = 'Page not found',
  });
}
