import 'package:daktela_connector/src/queries/daktela_filter.dart';
import 'package:test/test.dart';

void main() {
  test('Tests construction of FilterField', _filterFieldTest);
  test('Tests construction of Filter', _filterTest);
}

void _filterFieldTest() {
  var f = DaktelaFilterField(field: 'xxx', operator: 'isnull');
  expect(f.field, 'xxx');
  expect(f.operator, 'isnull');
  expect(f.value, isNull);
  expect(f.ignoreCase, false);

  f = DaktelaFilterField.fromJson({'field': 'bla', 'operator': 'neq', 'value': 'noname', 'ignoreCase': 'true'});
  expect(f.field, 'bla');
  expect(f.operator, 'neq');
  expect(f.value, ['noname']);
  expect(f.ignoreCase, true);
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
