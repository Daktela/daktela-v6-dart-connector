# Daktela V6 Dart Connector

Daktela V6 Dart Connector is a library that enables your Dart/Flutter application to connect to your [Daktela V6 REST API](https://customer.daktela.com/apihelp/v6/global/general-information). This connector requires you to have the [Daktela Contact Centre](https://daktela.com/) application already purchased, installed, and ready for use. The Daktela Contact Centre is an application enabling all-in-one handling of all customer communication coming through various channels, for example calls, e-mails, web chats, SMS, or social media.

## Setup

The connector requires following prerequisites:

* Instance URL in the form of https://URL/
* Access token for each access to the Daktela V6 REST API based on required permissions

## Usage

`DaktelaConnector` is singleton class that allows you to send CRUD on your Daktela server.
It requires instance of configuration class `DaktelaConnectorConfig`, where you must specify instance URL at least and in most cases you probably also want to set a user's access token. Other options are listed below.

### DaktelaConnectorConfig
Configuration for `DaktelaConnector` with options:
* `url` - instance's URL (required), for example 'my.daktela.com',
* `accessToken` - user's access token used for authentication,
* `timeout` - request timeout (default: 10 second),
* `longPollingTimeout` - in case you implement your custom app pull data worker, you are allowed to set long polling requests timeout (default: 30 seconds),
* `userAgent` - your app user agent,
* `cookieAuth` - allows you to authenticate request through cookies (default value is false and in that case access token will be added into request's query parameters),
* `logger` - instance of `DaktelaLogger` that allows you to implement custom logging method,
* `errors` - instance of `DaktelaErrorMessages` for overriding default error messages defined by connector.

```dart
var logger = DaktelaLogger(
  callback: (String message, {Object? error, DaktelaLogLevel? logLevel, StackTrace? stackTrace}) {
    print(message);
    if (error != null) {
      print('Error:  $error');
    }
    if (stackTrace != null) {
      print('StackTrace:  $stackTrace');
    }
  },
);

var config = DaktelaConnectorConfig(
  url: 'my.daktela.com',
  accessToken: 'e10adc3949ba59abbe56e057f20f883e',
  userAgent: 'MyDaktelaClient-1.0.0',
  cookieAuth: true,
  logger: logger,
  errors: DaktelaErrorMessages(general: 'Ooops'),
);
```

### DaktelaConnector
Class allows you to call GET, POST, PUT or DELETE requests. There are 2 necessary steps:
1) obtain instance of `DaktelaConnector` through getter `instance`,
2) set instance of `DaktelaConnectorConfig` through setter `config`.

Then you are allowed to call methods `get`, `post`, `put` and `delete` that use standard HTTP methods.
Methods parameters:
* `endpoint` - name of endpoint (required), for example 'tickets.json'
* `query` - map (`Map<String, dynamic>`) of query parameters, we recommend you to use `DaktelaQueryMap` to build request's query,
* `payload` - map (`Map<String, dynamic>`) of POST or PUT requests' payload,
* `nestedDecoding` - flag for response decoding (default is true for standard response decoding),
* `internalEndpoint` - flag for use `/internal` endpoint prefix instead of standard `/api/v6` (default: false),
* `longPollingRequest` - flag for use long polling request timeout (default: false).

Standard response from server is an instance of `DaktelaResponse` with properties `statusCode` (`int`), `result` (`dynamic`) and `total` (`int?`).

Request may throw an exception `DaktelaException` or its subclasses (`DaktelaUnauthorizedException`, `DaktelaNotFoundException`).

```dart
var connector = DaktelaConnector.instance..config = config;

String? accessToken;
try {
  var r = await connector.post('login.json', payload: {
    'username': 'user_1',
    'password': 'password_1',
    'only_token': '1',
  });
  accessToken = r.result as String;
} catch (e) {
  print(e);
}
```

### Sorting, paging and filtering
In case of processing larger data volumes pagination, sorting, filtering and fields projection might be used. You can create map of query parameters from these options through `DaktelaQueryMap` and its static method `build` with parameters: 
* `DaktelaFilter? filter` - filter defining class which is composed by atomic field parts (instances of `DaktelaFilterField`), 
* `DaktelaSort? sort` - simple class for sorting data by one or more fields. It consists of atomic parts as well (instances of `DaktelaSort`), 
* `DaktelaPagination? pagination` - useful when you want to load data dynamically in batches.
* `String? search` - for some endpoints you may use full text search, 
* `List<String>? fields` - allows you to specify which fields of model should be returned.

Complex example of requesting Tickets model with query parameters:
```dart
var r = await connector.get(
  'tickets.json',
  queryParameters: DaktelaQueryMap.build(
      pagination: DaktelaPagination(take: 3),
      fields: ['name', 'title', 'category', 'user'],
      filter: DaktelaFilter.simple(DaktelaFilterField(field: 'stage', operator: 'eq', value: ['CLOSE'])),
      sort: DaktelaSort.simple(DaktelaSortField(field: 'edited', direction: 'desc')),
  ),
);
```

### Example
Check simple usage example in `example/example.dart`. You will find there:
* customized logging through `DaktelaLogger`,
* obtaining access token (log in),
* request on `tickets.json` endpoint with example usage of `DaktelaQueryMap`.