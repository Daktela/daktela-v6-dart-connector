import 'dart:async';
import 'dart:convert';

import 'package:daktela_connector/src/daktela_connector_config.dart';
import 'package:daktela_connector/src/daktela_logger.dart';
import 'package:http/http.dart' as http;

class DaktelaConnector {
  static const _apiPrefix = 'api/v6/';
  static const _internalPrefix = 'internal/';

  static DaktelaConnector? _instance;

  late DaktelaConnectorConfig _config;
  final _defaultErrors = DaktelaErrorMessages();

  DaktelaConnector._();

  /// instance getter
  static DaktelaConnector get instance => _instance ??= DaktelaConnector._();

  DaktelaErrorMessages get _errors => _config.errors ?? _defaultErrors;

  /// config setter
  set config(DaktelaConnectorConfig config) {
    _config = config;
  }

  Map<String, String> _prepareHeaders({Map<String, String>? headers}) {
    headers ??= {};
    if (_config.userAgent.isNotEmpty) {
      headers['User-Agent'] = _config.userAgent;
    }
    if (_config.accessToken.isNotEmpty && _config.cookieAuth) {
      headers['Cookie'] = 'c_user=${_config.accessToken}';
    }
    return headers;
  }

  Map<String, dynamic>? _enrichQueryParams(Map<String, dynamic>? query) {
    if (!_config.cookieAuth) {
      query ??= {};
      query['accessToken'] = _config.accessToken;
    }
    return query;
  }

  Map<String, String> get _contentTypeJson => {'Content-Type': 'application/json'};

  /// HTTP GET method
  /// [endpoint] - name of endpoint
  /// [queryParameters] - map of query parameters (we recommend you to use [DaktelaQueryMap] to build request's query)
  /// [nestedDecoding] - flag for response decoding (default is true for standard response decoding)
  /// [internalEndpoint] - flag for use `/internal` endpoint prefix instead of standard `/api/v6` (default is false)
  /// [longPollingRequest] - flag for use long polling request timeout (default is false).
  Future<DaktelaResponse> get(String endpoint, {Map<String, dynamic>? queryParameters, bool nestedDecoding = true, bool internalEndpoint = false, bool longPollingRequest = false}) async {
    Map<String, String> headers = _prepareHeaders();
    _logRequest('GET', endpoint, null, queryParameters, headers);
    try {
      http.Response response =
          await http.get(_buildUri(endpoint, queryParameters, internal: internalEndpoint), headers: headers).timeout(longPollingRequest ? _config.longPollingTimeout : _config.timeout);
      return _parseResponse(response, nestedDecoding);
    } on TimeoutException catch (e, st) {
      _config.logger?.log('Timeout', error: e, stackTrace: st);
      throw DaktelaException(0, _errors.timeout);
    }
  }

  /// HTTP POST method
  /// [endpoint] - name of endpoint
  /// [payload] - map of payload
  /// [queryParameters] - map of query parameters (we recommend you to use [DaktelaQueryMap] to build request's query)
  /// [nestedDecoding] - flag for response decoding (default is true for standard response decoding)
  Future<DaktelaResponse> post(String endpoint, {Map<String, dynamic>? payload, Map<String, dynamic>? queryParameters, bool nestedDecoding = true}) async {
    Map<String, String> headers = _prepareHeaders(headers: _contentTypeJson);
    _logRequest('POST', endpoint, payload, queryParameters, headers);
    try {
      http.Response response = await http.post(_buildUri(endpoint, queryParameters), body: jsonEncode(payload), headers: headers).timeout(_config.timeout);
      return _parseResponse(response, nestedDecoding);
    } on TimeoutException catch (e, st) {
      _config.logger?.log('Timeout', error: e, stackTrace: st);
      throw DaktelaException(0, _errors.timeout);
    }
  }

  /// HTTP PUT method
  /// [endpoint] - name of endpoint
  /// [payload] - map of payload
  /// [queryParameters] - map of query parameters (we recommend you to use [DaktelaQueryMap] to build request's query)
  /// [nestedDecoding] - flag for response decoding (default is true for standard response decoding)
  Future<DaktelaResponse> put(String endpoint, {Map<String, dynamic>? payload, Map<String, dynamic>? queryParameters, bool nestedDecoding = true}) async {
    Map<String, String> headers = _prepareHeaders(headers: _contentTypeJson);
    _logRequest('PUT', endpoint, payload, queryParameters, headers);
    try {
      http.Response response = await http.put(_buildUri(endpoint, queryParameters), body: jsonEncode(payload), headers: headers).timeout(_config.timeout);
      return _parseResponse(response, nestedDecoding);
    } on TimeoutException catch (e, st) {
      _config.logger?.log('Timeout', error: e, stackTrace: st);
      throw DaktelaException(0, _errors.timeout);
    }
  }

  /// HTTP PUT method
  /// [endpoint] - name of endpoint
  /// [queryParameters] - map of query parameters (we recommend you to use [DaktelaQueryMap] to build request's query)
  /// [nestedDecoding] - flag for response decoding (default is true for standard response decoding)
  Future<DaktelaResponse> delete(String endpoint, {Map<String, dynamic>? queryParameters, bool nestedDecoding = true}) async {
    Map<String, String> headers = _prepareHeaders();
    _logRequest('DELETE', endpoint, null, queryParameters, headers);
    try {
      http.Response response = await http.delete(_buildUri(endpoint, queryParameters), headers: headers).timeout(_config.timeout);
      if (response.statusCode == 204) {
        return DaktelaResponse(response.statusCode, null, null);
      }
      throw DaktelaException(response.statusCode, _errors.general);
    } on TimeoutException catch (e, st) {
      _config.logger?.log('Timeout', error: e, stackTrace: st);
      throw DaktelaException(0, _errors.timeout);
    }
  }

  Uri _buildUri(String endpoint, Map<String, dynamic>? query, {bool internal = false}) => Uri.https(_config.url, '${internal ? _internalPrefix : _apiPrefix}$endpoint', _enrichQueryParams(query));

  void _logRequest(String method, String endpoint, Map<String, dynamic>? payload, Map<String, dynamic>? queryParameters, Map<String, String>? headers) {
    String output = '$method $endpoint';
    if (queryParameters != null) {
      output += ', QueryParams: $queryParameters';
    }
    if (payload != null) {
      output += ', JSON payload: ${jsonEncode(payload)}';
    }
    _config.logger?.log(output, logLevel: DaktelaLogLevel.minimal);
    if (headers != null) {
      _config.logger?.log(' Headers: $headers', logLevel: DaktelaLogLevel.verbose);
    }
  }

  void _logResponse(int statusCode, String url, dynamic body) {
    _config.logger?.log('->  $statusCode $url', logLevel: DaktelaLogLevel.minimal);
    _config.logger?.log('->  Response: $body', logLevel: DaktelaLogLevel.verbose);
  }

  DaktelaResponse _parseResponse(http.Response response, bool nestedDecoding) {
    Map<String, dynamic> body = response.body.isNotEmpty ? jsonDecode(response.body) : {};
    _logResponse(response.statusCode, response.request?.url.toString() ?? '', body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      dynamic result = body['result'];
      int? total;
      if (nestedDecoding && result is Map<String, dynamic>) {
        total = result['total'];
        if (result['data'] != null) {
          result = result['data'];
        }
      }
      return DaktelaResponse(response.statusCode, result, total);
    } else if (response.statusCode == 401) {
      throw DaktelaUnauthorizedException(_config.errors?.unauthorized ?? '');
    } else if (response.statusCode == 404) {
      throw DaktelaNotFoundException(_config.errors?.notFound ?? '');
    }
    String? apiError = _parseApiError(body);
    throw DaktelaException(response.statusCode, apiError ?? _errors.general);
  }

  String? _parseApiError(Map<String, dynamic> body) {
    if (body.containsKey('error')) {
      dynamic error = body['error'];
      if (error is List) {
        return _getApiErrorValues(error);
      } else if (error is Map<String, dynamic>) {
        return _iterateThroughErrorObjects(error);
      }
    }
    return null;
  }

  String? _getApiErrorValues(List<dynamic> errors) {
    List<String> errorMessages = [];
    for (var element in errors) {
      if (element is String) {
        errorMessages.add(element);
      } else if (element is Map<String, dynamic>) {
        String? errorMessage = _iterateThroughErrorObjects(element);
        if (errorMessage != null) {
          errorMessages.add(errorMessage);
        }
      }
    }
    return errorMessages.isNotEmpty ? errorMessages.join(', ') : null;
  }

  String? _iterateThroughErrorObjects(Map<String, dynamic> map) {
    List<String> errorMessages = [];
    for (var key in map.keys) {
      if (map[key] is Map<String, dynamic>) {
        String? errorMessage = _iterateThroughErrorObjects(map[key]);
        if (errorMessage != null) {
          errorMessages.add(errorMessage);
        }
      } else if (map[key] is String) {
        errorMessages.add('$key: ${map[key]}');
      } else if (map[key] is List) {
        String? errorMessage = _getApiErrorValues(map[key]);
        if (errorMessage != null) {
          errorMessages.add('$key: $errorMessage');
        }
      }
    }
    return errorMessages.isNotEmpty ? errorMessages.join(', ') : null;
  }
}

/// Error response from server
/// [statusCode] of response,
/// error [message].
class DaktelaException implements Exception {
  final int statusCode;
  final String message;

  DaktelaException(this.statusCode, this.message);

  @override
  String toString() {
    return message;
  }
}

/// Thrown in case of invalid credentials
class DaktelaUnauthorizedException extends DaktelaException {
  DaktelaUnauthorizedException(String message) : super(401, message);
}

/// Thrown in case of invalid credentials
class DaktelaNotFoundException extends DaktelaException {
  DaktelaNotFoundException(String message) : super(404, message);
}

/// Standard response from server
/// [statusCode] of response,
/// [result] contains returned data,
/// [total] is total number of records (in case this number is contained in response).
class DaktelaResponse {
  final int statusCode;
  final dynamic result;
  final int? total;

  DaktelaResponse(this.statusCode, this.result, this.total);
}
