import 'package:daktela_connector/daktela_connector.dart';
import 'package:test/test.dart';

void main() {
  test('Tests construction of Sort and SortField', _constructTest);
  test('Tests parsing of sort direction', _parseTest);
}

void _constructTest() {
  var field = DaktelaSortField(field: 'super_custom', direction: 'custom_dir');
  expect(field.field, 'super_custom');
  expect(field.direction, 'custom_dir');

  var field2 = DaktelaSortField(field: 'edited', direction: 'desc');
  expect(field2.field, 'edited');
  expect(field2.direction, 'desc');

  var sort = DaktelaSort(fields: [field, field2]);
  expect(sort.fields, containsAllInOrder([field, field2]));

  var sort2 = DaktelaSort.simple(field2);
  expect(sort2.fields.length, 1);
  expect(sort2.fields.first, field2);
}

void _parseTest() {
  Map<String, dynamic> json = {'field': 'title', 'dir': 'asc'};
  var sortField = DaktelaSortField.fromJson(json);
  expect(sortField.field, 'title');
  expect(sortField.direction, 'asc');

  List<dynamic> json2 = [
    {'field': 'firstname', 'dir': 'asc'},
    {'field': 'lastname', 'dir': 'desc'}
  ];
  var sort = DaktelaSort.fromJson(json2);
  expect(sort.fields.length, 2);
  expect(sort.fields.first.field, 'firstname');
  expect(sort.fields.first.direction, 'asc');
  expect(sort.fields[1].field, 'lastname');
  expect(sort.fields[1].direction, 'desc');
}
