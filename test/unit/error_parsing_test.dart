import 'package:daktela_connector/daktela_connector.dart';
import 'package:http/http.dart';
import 'package:test/test.dart';

void main() {
  test('Parse error response test', () {
    DaktelaConnector.instance.config = DaktelaConnectorConfig(url: 'test');
    try {
      DaktelaConnector.instance.parseResponse(Response('{"error": {"bool": true, "int": 1, "string": "test", "map": {"key": "value"}, "list": ["test"]}, "result": null}', 400), true);
    } catch (e) {
      var error = e as DaktelaException;
      expect(error.statusCode, 400);
      expect(error.message, 'bool: true, int: 1, string: test, key: value, list: test');
    }
  });
}
