import 'package:daktela_connector/daktela_connector.dart';
import 'package:dotenv/dotenv.dart';
import 'package:test/test.dart';

void main() {
  int currentDateTime = DateTime.now().microsecondsSinceEpoch;

  late String instance;
  late String accessToken;
  late DaktelaConnector connector;

  setUp(() {
    var env = DotEnv(includePlatformEnvironment: true)..load();
    if (!env.isEveryDefined(['instance', 'accessToken'])) {
      throw Exception('Missing env variables');
    }
    instance = env['instance'] ?? '';
    accessToken = env['accessToken'] ?? '';
    connector = DaktelaConnector.instance
      ..config = DaktelaConnectorConfig(
        url: instance,
        accessToken: accessToken,
        logger: DaktelaLogger(
          callback: (String message, {Object? error, DaktelaLogLevel? logLevel, StackTrace? stackTrace}) {
            print(message);
            if (error != null) {
              print('  $error');
            }
            if (stackTrace != null) {
              print('  $stackTrace');
            }
          },
        ),
      );
  });

  test('Initial test', () async {
    var connector = DaktelaConnector.instance..config = DaktelaConnectorConfig(url: instance);
    var response = await connector.get('whoim.json');
    expect(response.statusCode, 200);
    expect(response.result, isA<Map<String, dynamic>>());
    expect(response.total, null);
    var data = response.result as Map<String, dynamic>;
    expect(data['version'], isNotNull);
    expect(data.containsKey('user'), isTrue);
    expect(data['user'], isNull);
  });

  test('Access token test', () async {
    var connector = DaktelaConnector.instance..config = DaktelaConnectorConfig(url: instance, accessToken: accessToken, cookieAuth: true);
    var response = await connector.get('whoim.json');
    expect(response.statusCode, 200);
    expect(response.result, isA<Map<String, dynamic>>());
    var data = response.result as Map<String, dynamic>;
    expect(data.containsKey('user'), isTrue);
    expect(data['user'], isNotNull);
    expect(data['user']['_sys'], isNotNull);
    expect(data['user']['_sys']['accessToken'], accessToken);
  });

  test('Exception test', () async {
    expect(() async => await connector.get('xxx'), throwsA(isA<DaktelaException>()));
    expect(() async => await connector.get('tickets/xxx'), throwsA(isA<DaktelaNotFoundException>()));
    connector.config = DaktelaConnectorConfig(url: instance);
    expect(() async => await connector.post('login', payload: {'username': 'xyz', 'password': '-123'}), throwsA(isA<DaktelaUnauthorizedException>()));
  });

  group('CRUD test', () {
    test('POST request test', () async {
      var payload = {
        'name': 'test_create_$currentDateTime',
        'title': 'test_create_$currentDateTime',
      };
      var response = await connector.post('statuses.json', payload: payload);
      expect(response.statusCode, 201);
      expect(response.result, isA<Map<String, dynamic>>());
      var data = response.result as Map<String, dynamic>;
      expect(data['name'], payload['name']);
      print('POST done');
    });

    test('GET request test', () async {
      var response = await connector.get('statuses/test_create_$currentDateTime.json');
      expect(response.statusCode, 200);
      expect(response.result, isA<Map<String, dynamic>>());
      var data = response.result as Map<String, dynamic>;
      expect(response.time, isA<DateTime>());
      expect(data['name'], 'test_create_$currentDateTime');
    });

    test('GET all request test', () async {
      var map = DaktelaQueryMap.build(filter: DaktelaFilter.simple(DaktelaFilterField(field: 'name', operator: 'eq', value: ['test_create_$currentDateTime'])));
      var response = await connector.get('statuses.json', queryParameters: map);
      expect(response.statusCode, 200);
      expect(response.result, isA<List>());
      var data = response.result as List<dynamic>;
      expect(data.length, 1);
      expect(data[0], isA<Map<String, dynamic>>());
      var object = data[0] as Map<String, dynamic>;
      expect(object.length, 9);
      expect(object['name'], 'test_create_$currentDateTime');
    });

    test('PUT request test', () async {
      var response = await connector.put('statuses/test_create_$currentDateTime.json', payload: {'description': 'test'});
      expect(response.statusCode, 200);
      expect(response.result, isA<Map<String, dynamic>>());
      var data = response.result as Map<String, dynamic>;
      expect(data['description'], 'test');
    });

    test('DELETE request test', () async {
      var response = await connector.delete('statuses/test_create_$currentDateTime.json');
      expect(response.statusCode, 204);
      expect(response.result, isNull);
    });
  });
}
