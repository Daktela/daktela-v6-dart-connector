import 'package:daktela_connector/daktela_connector.dart';
import 'package:test/test.dart';

void main() {
  List<String> messages = [];
  List<Object?> errors = [];
  List<StackTrace?> stackTraces = [];
  late DaktelaLogger logger;

  setUp(() {
    logger = DaktelaLogger(callback: (String message, {Object? error, DaktelaLogLevel? logLevel, StackTrace? stackTrace}) {
      messages.add(message);
      errors.add(error);
      stackTraces.add(stackTrace);
    });
  });

  test('Logger test', () {
    logger.log('first');
    expect(messages.length, 1);
    expect(messages.first, 'first');
    expect(errors.length, 1);
    expect(errors.first, null);
    expect(stackTraces.length, 1);
    expect(stackTraces.first, null);

    logger.log('excluded message', logLevel: DaktelaLogLevel.verbose);
    expect(messages.length, 1);
    expect(errors.length, 1);
    expect(stackTraces.length, 1);

    var e = RangeError('out ouf bounds');
    logger.log('second', error: e);
    expect(messages.length, 2);
    expect(messages.last, 'second');
    expect(errors.length, 2);
    expect(errors.last, e);
    expect(stackTraces.length, 2);
    expect(stackTraces.last, null);
  });
}
