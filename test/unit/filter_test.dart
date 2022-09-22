import 'package:daktela_connector/daktela_connector.dart';
import 'package:test/test.dart';

void main() {
  test('Tests construction of FilterField', _filterFieldTest);
  test('Tests construction of Filter', _filterTest);
  test('Tests parsing of Filter and FilterField', _parseTest);
}

void _filterFieldTest() {
  var f = DaktelaFilterField(field: 'xxx', operator: 'isnull');
  expect(f.field, 'xxx');
  expect(f.operator, 'isnull');
  expect(f.value, isNull);
  expect(f.ignoreCase, false);
}

void _filterTest() {
  var f = DaktelaFilterField(field: 'bla', operator: 'neq', value: ['noname']);
  var filter = DaktelaFilter.simple(f);
  expect(filter.logic, 'and');
  expect(filter.filters, null);
  expect(filter.fields, isNotNull);
  expect(filter.fields!.length, 1);
  expect(filter.fields!.first, f);

  filter = DaktelaFilter(logic: 'and', filters: [
    DaktelaFilter(logic: 'or', fields: [
      DaktelaFilterField(field: 'item', operator: 'isnotnull'),
      DaktelaFilterField(field: 'type', operator: 'eq', value: ['']),
    ]),
  ], fields: [
    DaktelaFilterField(field: 'action', operator: 'eq', value: ['CLOSE'])
  ]);
  expect(filter.logic, 'and');
  expect(filter.fields, isNotNull);
  expect(filter.fields!.length, 1);
  f = filter.fields!.first;
  expect(f.field, 'action');
  expect(f.operator, 'eq');
  expect(f.value, ['CLOSE']);

  expect(filter.filters, isNotNull);
  expect(filter.filters!.length, 1);
  expect(filter.filters!.first.logic, 'or');
  expect(filter.filters!.first.filters, isNull);
  expect(filter.filters!.first.fields!, isNotNull);
  expect(filter.filters!.first.fields!.length, 2);

  f = filter.filters!.first.fields![0];
  expect(f.field, 'item');
  expect(f.operator, 'isnotnull');
  expect(f.value, isNull);
  expect(f.ignoreCase, false);

  f = filter.filters!.first.fields![1];
  expect(f.field, 'type');
  expect(f.operator, 'eq');
  expect(f.value, ['']);

  filter = DaktelaFilter(logic: 'xxx');
  expect(filter.logic, 'xxx');
  expect(filter.filters, isNull);
  expect(filter.fields, isNull);
}

void _parseTest() {
  var f = DaktelaFilterField.fromJson({'field': 'bla', 'operator': 'neq', 'value': 'noname', 'ignoreCase': 'true'});
  expect(f.field, 'bla');
  expect(f.operator, 'neq');
  expect(f.value, ['noname']);
  expect(f.ignoreCase, true);

  f = DaktelaFilterField.fromJson({'field': 'bla', 'operator': 'neq', 'value': null});
  expect(f.field, 'bla');
  expect(f.operator, 'neq');
  expect(f.value, null);
  expect(f.ignoreCase, false);

  f = DaktelaFilterField.fromJson({'field': 'bla', 'operator': 'neq', 'value': 11});
  expect(f.field, 'bla');
  expect(f.operator, 'neq');
  expect(f.value, ['11']);
  expect(f.ignoreCase, false);

  var filter = DaktelaFilter.fromJson({'field': 'firstname', 'operator': 'eq', 'value': 'John'});
  expect(filter.logic, 'and');
  expect(filter.filters, isEmpty);
  expect(filter.fields?.length, 1);

  f = filter.fields!.first;
  expect(f.field, 'firstname');
  expect(f.operator, 'eq');
  expect(f.value, ['John']);

  filter = DaktelaFilter.fromJson([
    {'field': 'firstname', 'operator': 'eq', 'value': 'John'},
    {'field': 'lastname', 'operator': 'neq', 'value': 'Smith'}
  ]);
  expect(filter.logic, 'and');
  expect(filter.filters, isEmpty);
  expect(filter.fields?.length, 2);

  f = filter.fields![0];
  expect(f.field, 'firstname');
  expect(f.operator, 'eq');
  expect(f.value, ['John']);
  f = filter.fields![1];
  expect(f.field, 'lastname');
  expect(f.operator, 'neq');
  expect(f.value, ['Smith']);

  var json = {
    'logic': 'or',
    'filters': [
      {'field': 'firstname', 'operator': 'eq', 'value': 'John'},
      {'field': 'firstname', 'operator': 'eq', 'value': 'James'},
      {
        'logic': 'and',
        'filters': [
          {'field': 'firstname', 'operator': 'eq', 'value': 'David'},
          {'field': 'lastname', 'operator': 'eq', 'value': 'Smith'}
        ]
      }
    ]
  };

  filter = DaktelaFilter.fromJson(json);
  expect(filter.logic, 'or');
  expect(filter.fields?.length, 2);
  expect(filter.filters?.length, 1);

  f = filter.fields![0];
  expect(f.field, 'firstname');
  expect(f.operator, 'eq');
  expect(f.value, ['John']);
  f = filter.fields![1];
  expect(f.field, 'firstname');
  expect(f.operator, 'eq');
  expect(f.value, ['James']);

  filter = filter.filters!.first;
  expect(filter.logic, 'and');
  expect(filter.filters, isEmpty);
  expect(filter.fields?.length, 2);

  f = filter.fields![0];
  expect(f.field, 'firstname');
  expect(f.operator, 'eq');
  expect(f.value, ['David']);
  f = filter.fields![1];
  expect(f.field, 'lastname');
  expect(f.operator, 'eq');
  expect(f.value, ['Smith']);

  json = {
    'logic': 'and',
    'filters': [
      {'field': 'user', 'value': '_LOGGED', 'operator': 'eq'},
      {
        'logic': 'or',
        'filters': [
          {
            'field': 'stage',
            'value': ['OPEN', 'WAIT'],
            'operator': 'in'
          },
          {
            'field': 'stage',
            'value': ['CLOSE'],
            'operator': 'in'
          }
        ]
      }
    ]
  };

  filter = DaktelaFilter.fromJson(json);
  expect(filter.logic, 'and');

  expect(filter.fields?.length, 1);
  f = filter.fields!.first;
  expect(f.field, 'user');
  expect(f.operator, 'eq');
  expect(f.value, ['_LOGGED']);

  expect(filter.filters?.length, 1);
  filter = filter.filters!.first;
  expect(filter.logic, 'or');
  expect(filter.filters, isEmpty);
  expect(filter.fields?.length, 2);

  f = filter.fields!.first;
  expect(f.field, 'stage');
  expect(f.operator, 'in');
  expect(f.value, ['OPEN', 'WAIT']);

  f = filter.fields![1];
  expect(f.field, 'stage');
  expect(f.operator, 'in');
  expect(f.value, ['CLOSE']);
}
