import 'package:daktela_connector/daktela_connector.dart';
import 'package:dotenv/dotenv.dart';
import 'package:test/test.dart';

void main() {
  int currentDateTime = DateTime.now().microsecondsSinceEpoch;

  late String instance;
  late String accessToken;
  late String queueName;
  late DaktelaConnector connector;

  setUp(() {
    var env = DotEnv(includePlatformEnvironment: true)..load();
    if (!env.isEveryDefined(['instance', 'accessToken'])) {
      throw Exception('Missing env variables');
    }
    instance = env['instance'] ?? '';
    accessToken = env['accessToken'] ?? '';
    queueName = env['queue'] ?? '';
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
        'number': '+420111222333',
        'action': 5,
        'queue': queueName,
      };
      var response = await connector.post('campaignsRecords.json', payload: payload);
      expect(response.statusCode, 201);
      expect(response.result, isA<Map<String, dynamic>>());
      var data = response.result as Map<String, dynamic>;
      expect(data['name'], payload['name']);
      expect(data['number'], payload['number']);
      expect(data['action'], '${payload['action']}');
      expect('${data['record_type']['name']}', payload['queue']);
      print('POST done');
    });

    test('GET request test', () async {
      var response = await connector.get('campaignsRecords/test_create_$currentDateTime.json');
      expect(response.statusCode, 200);
      expect(response.result, isA<Map<String, dynamic>>());
      var data = response.result as Map<String, dynamic>;
      expect(data['name'], 'test_create_$currentDateTime');
    });

    test('GET all request test', () async {
      var map = DaktelaQueryMap.build(filter: DaktelaFilter.simple(DaktelaFilterField(field: 'name', operator: 'eq', value: ['test_create_$currentDateTime'])), fields: ['name', 'number']);
      var response = await connector.get('campaignsRecords.json', queryParameters: map);
      expect(response.statusCode, 200);
      expect(response.result, isA<List>());
      var data = response.result as List<dynamic>;
      expect(data.length, 1);
      expect(data[0], isA<Map<String, dynamic>>());
      var object = data[0] as Map<String, dynamic>;
      expect(object.length, 2);
      expect(object['name'], 'test_create_$currentDateTime');
      expect(object['number'], '+420111222333');
    });

    test('PUT request test', () async {
      var response = await connector.put('campaignsRecords/test_create_$currentDateTime.json', payload: {'number': '987654321'});
      expect(response.statusCode, 200);
      expect(response.result, isA<Map<String, dynamic>>());
      var data = response.result as Map<String, dynamic>;
      expect(data['number'], '987654321');
    });

    test('DELETE request test', () async {
      var response = await connector.delete('campaignsRecords/test_create_$currentDateTime.json');
      expect(response.statusCode, 204);
      expect(response.result, isNull);
    });
  });
}
