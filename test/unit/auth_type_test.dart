import 'package:daktela_connector/daktela_connector.dart';
import 'package:test/test.dart';

void main() {
  group('DaktelaAuthType', () {
    test('default effectiveAuthType is header', () {
      var config = DaktelaConnectorConfig(url: 'test.daktela.com');
      expect(config.effectiveAuthType, DaktelaAuthType.header);
    });

    test('explicit authType takes precedence over cookieAuth', () {
      // ignore: deprecated_member_use_from_same_package
      var config = DaktelaConnectorConfig(
        url: 'test.daktela.com',
        authType: DaktelaAuthType.header,
        cookieAuth: true,
      );
      expect(config.effectiveAuthType, DaktelaAuthType.header);
    });

    test('cookieAuth=true maps to DaktelaAuthType.cookie for backward compatibility', () {
      // ignore: deprecated_member_use_from_same_package
      var config = DaktelaConnectorConfig(
        url: 'test.daktela.com',
        cookieAuth: true,
      );
      expect(config.effectiveAuthType, DaktelaAuthType.cookie);
    });

    test('cookieAuth=false maps to DaktelaAuthType.header for backward compatibility', () {
      // ignore: deprecated_member_use_from_same_package
      var config = DaktelaConnectorConfig(
        url: 'test.daktela.com',
        cookieAuth: false,
      );
      expect(config.effectiveAuthType, DaktelaAuthType.header);
    });

    test('authType=queryParam works correctly', () {
      var config = DaktelaConnectorConfig(
        url: 'test.daktela.com',
        authType: DaktelaAuthType.queryParam,
      );
      expect(config.effectiveAuthType, DaktelaAuthType.queryParam);
    });

    test('authType=cookie works correctly', () {
      var config = DaktelaConnectorConfig(
        url: 'test.daktela.com',
        authType: DaktelaAuthType.cookie,
      );
      expect(config.effectiveAuthType, DaktelaAuthType.cookie);
    });

    test('authType=header works correctly', () {
      var config = DaktelaConnectorConfig(
        url: 'test.daktela.com',
        authType: DaktelaAuthType.header,
      );
      expect(config.effectiveAuthType, DaktelaAuthType.header);
    });

    test('copyWith preserves authType', () {
      var config = DaktelaConnectorConfig(
        url: 'test.daktela.com',
        authType: DaktelaAuthType.header,
      );
      var copied = config.copyWith(accessToken: 'newToken');
      expect(copied.effectiveAuthType, DaktelaAuthType.header);
    });

    test('copyWith can change authType', () {
      var config = DaktelaConnectorConfig(
        url: 'test.daktela.com',
        authType: DaktelaAuthType.header,
      );
      var copied = config.copyWith(authType: DaktelaAuthType.cookie);
      expect(copied.effectiveAuthType, DaktelaAuthType.cookie);
    });
  });

  group('DaktelaConnector headers preparation', () {
    late DaktelaConnector connector;

    setUp(() {
      connector = DaktelaConnector.instance;
    });

    test('authType=header adds X-AUTH-TOKEN header', () {
      connector.config = DaktelaConnectorConfig(
        url: 'test.daktela.com',
        accessToken: 'test-token',
        authType: DaktelaAuthType.header,
      );
      var headers = connector.prepareHeaders();
      expect(headers['X-AUTH-TOKEN'], 'test-token');
      expect(headers['Cookie'], isNot(contains('c_user=')));
    });

    test('authType=cookie adds c_user to Cookie', () {
      connector.config = DaktelaConnectorConfig(
        url: 'test.daktela.com',
        accessToken: 'test-token',
        authType: DaktelaAuthType.cookie,
      );
      var headers = connector.prepareHeaders();
      expect(headers['Cookie'], contains('c_user=test-token'));
      expect(headers.containsKey('X-AUTH-TOKEN'), isFalse);
    });

    test('authType=queryParam does not add auth headers', () {
      connector.config = DaktelaConnectorConfig(
        url: 'test.daktela.com',
        accessToken: 'test-token',
        authType: DaktelaAuthType.queryParam,
      );
      var headers = connector.prepareHeaders();
      expect(headers.containsKey('X-AUTH-TOKEN'), isFalse);
      expect(headers['Cookie'], isNot(contains('c_user=')));
    });

    test('empty accessToken does not add X-AUTH-TOKEN header', () {
      connector.config = DaktelaConnectorConfig(
        url: 'test.daktela.com',
        accessToken: '',
        authType: DaktelaAuthType.header,
      );
      var headers = connector.prepareHeaders();
      expect(headers.containsKey('X-AUTH-TOKEN'), isFalse);
    });

    test('empty accessToken does not add c_user cookie', () {
      connector.config = DaktelaConnectorConfig(
        url: 'test.daktela.com',
        accessToken: '',
        authType: DaktelaAuthType.cookie,
      );
      var headers = connector.prepareHeaders();
      expect(headers['Cookie'], isNot(contains('c_user=')));
    });
  });
}
