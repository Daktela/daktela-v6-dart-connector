import 'package:daktela_connector/daktela_connector.dart';
import 'package:daktela_connector/src/daktela_connector_config.dart';

void main() async {
  const instance = 'mydaktela.daktela.com';

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
    url: instance,
  );

  var connector = DaktelaConnector.instance..config = config;

  String? accessToken;
  try {
    // obtain user's access token
    var r = await connector.post('login.json', payload: {
      'username': 'user_1',
      'password': 'password_1',
      'only_token': '1',
    });
    accessToken = r.result as String;
    print(r.result);
  } on DaktelaException catch (e) {
    print(e);
  }

  if (accessToken != null) {
    config = DaktelaConnectorConfig(
      url: instance,
      accessToken: accessToken,
      logger: logger,
      errors: DaktelaErrorMessages(general: 'Ooops'),
    );

    connector = DaktelaConnector.instance..config = config;
    try {
      // get static info about user
      var r = await connector.get('whoim.json');
      print(r.result['user']['title']);

      // get last 3 not closed tickets (ordered descend by edited time)
      r = await connector.get(
        'tickets.json',
        queryParameters: DaktelaQueryMap.build(
          pagination: DaktelaPagination(take: 3),
          fields: ['name', 'title', 'category', 'user'],
          filter: DaktelaFilter.simple(DaktelaFilterField(field: 'stage', operator: 'eq', value: ['CLOSE'])),
          sort: DaktelaSort.simple(DaktelaSortField(field: 'edited', direction: 'desc')),
        ),
      );
      print('Tickets count: ${r.total}');
      (r.result as List).forEach((e) {
        print('Ticket(name=${e['name']}, title=${e['title']}, category=${e['category']['title']}), user=${e['user'] != null ? e['user']['title'] : 'null'}');
      });
    } on DaktelaException catch (e) {
      print(e);
    }
  }
}
