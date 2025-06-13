import 'package:daktela_connector/src/daktela_logger.dart';

/// Configuration used in [DaktelaConnector]
/// [url] - URL of Daktela instance
/// [accessToken] - user's access token used for authentication
/// [timeout] - request timeout
/// [longPollingTimeout] - in case you implement your custom app pull data worker, you are allowed to set long polling requests timeout
/// [userAgent] - your app user agent
/// [cookieAuth] - allows you to authenticate request through cookies (default value is false and in that case access token will be added into request's query parameters)
/// [acceptLanguage] - Accept-Language header value
/// [clientTimeZone] - client time zone (IANA TZ format, e.g. 'Europe/Prague'). NOTE: time zone is client's time zone so it's applied for authorized requests only.
/// [logger] - instance of [DaktelaLogger]
/// [errors] - instance of [DaktelaErrorMessages]
/// [refreshToken] - new logic from v32 - tokens are updated through refresh token
class DaktelaConnectorConfig {
  final String url;
  final String accessToken;
  final String? refreshToken;

  final Duration timeout;
  final Duration longPollingTimeout;

  final String userAgent;
  final bool cookieAuth;
  final String acceptLanguage;
  final String clientTimeZone;

  final DaktelaLogger? logger;
  final DaktelaErrorMessages? errors;

  DaktelaConnectorConfig({
    required this.url,
    this.accessToken = '',
    this.timeout = const Duration(seconds: 10),
    this.longPollingTimeout = const Duration(seconds: 30),
    this.userAgent = '',
    this.cookieAuth = false,
    this.acceptLanguage = '',
    this.clientTimeZone = '',
    this.logger,
    this.refreshToken,
    this.errors,
  });

  DaktelaConnectorConfig copyWith({
    String? url,
    String? accessToken,
    String? refreshToken,
    Duration? timeout,
    Duration? longPollingTimeout,
    String? userAgent,
    bool? cookieAuth,
    String? acceptLanguage,
    String? clientTimeZone,
    DaktelaLogger? logger,
    DaktelaErrorMessages? errors,
  }) {
    return DaktelaConnectorConfig(
      url: url ?? this.url,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      timeout: timeout ?? this.timeout,
      longPollingTimeout: longPollingTimeout ?? this.longPollingTimeout,
      userAgent: userAgent ?? this.userAgent,
      cookieAuth: cookieAuth ?? this.cookieAuth,
      acceptLanguage: acceptLanguage ?? this.acceptLanguage,
      clientTimeZone: clientTimeZone ?? this.clientTimeZone,
      logger: logger ?? this.logger,
      errors: errors ?? this.errors,
    );
  }
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
