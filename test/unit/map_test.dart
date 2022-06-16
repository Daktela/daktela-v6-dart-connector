import 'package:daktela_connector/daktela_connector.dart';
import 'package:test/test.dart';

void main() {
  test('Tests query map', () {
    var m = DaktelaQueryMap.build(search: 'text to search');
    expect(m.length, 1);
    expect(m['q'], 'text to search');
  });

  test('Tests sort map', () {
    var s = DaktelaSortField(field: 'edited', direction: 'desc');
    var s2 = DaktelaSortField(field: 'created', direction: 'asc');

    var m = DaktelaQueryMap.build(sort: DaktelaSort.simple(s));
    expect(m.length, 2);
    expect(m['sort[0][field]'], 'edited');
    expect(m['sort[0][dir]'], 'desc');

    m = DaktelaQueryMap.build(sort: DaktelaSort(fields: [s, s2]));
    expect(m.length, 4);
    expect(m['sort[1][field]'], 'created');
    expect(m['sort[1][dir]'], 'asc');
  });

  test('Tests pagination map', () {
    var p = DaktelaPagination(take: 9);
    var m = DaktelaQueryMap.build(pagination: p);

    const skipKey = 'skip';
    const takeKey = 'take';

    expect(m.length, 2);
    expect(m[skipKey], '0');
    expect(m[takeKey], '9');

    m = DaktelaQueryMap.build(
        pagination: p
          ..next()
          ..next());
    expect(m[skipKey], '18');
    expect(m[takeKey], '9');
  });

  test('Tests filter map', () {
    var field = DaktelaFilterField(field: 'name', operator: 'eq', value: ['123']);
    var filter = DaktelaFilter.simple(field);
    var m = DaktelaQueryMap.build(filter: filter);

    expect(m.length, 4);

    expect(m['filter[logic]'], 'and');
    expect(m['filter[filters][0][field]'], 'name');
    expect(m['filter[filters][0][operator]'], 'eq');
    expect(m['filter[filters][0][value]'], '123');

    filter = DaktelaFilter(logic: 'or', filters: [
      DaktelaFilter(logic: 'or', fields: [
        DaktelaFilterField(field: 'item', operator: 'isnotnull'),
        DaktelaFilterField(field: 'type', operator: 'eq', value: [''], ignoreCase: true),
      ]),
    ], fields: [
      DaktelaFilterField(field: 'action', operator: 'neq', value: ['OPEN'])
    ]);
    m = DaktelaQueryMap.build(filter: filter);

    expect(m.length, 12);

    expect(m['filter[logic]'], 'or');
    expect(m['filter[filters][0][field]'], 'action');
    expect(m['filter[filters][0][operator]'], 'neq');
    expect(m['filter[filters][0][value]'], 'OPEN');
    expect(m['filter[filters][1][filters][0][field]'], 'item');
    expect(m['filter[filters][1][filters][0][operator]'], 'isnotnull');
    expect(m['filter[filters][1][filters][1][field]'], 'type');
    expect(m['filter[filters][1][filters][1][operator]'], 'eq');
    expect(m['filter[filters][1][filters][1][value]'], '');
    expect(m['filter[filters][1][filters][1][ignoreCase]'], 'true');

    filter = DaktelaFilter.simple(DaktelaFilterField(field: 'title', operator: 'in', value: ['xxx', 'yyy']));
    m = DaktelaQueryMap.build(filter: filter);

    expect(m.length, 5);

    expect(m['filter[logic]'], 'and');
    expect(m['filter[filters][0][field]'], 'title');
    expect(m['filter[filters][0][operator]'], 'in');
    expect(m['filter[filters][0][value][0]'], 'xxx');
    expect(m['filter[filters][0][value][1]'], 'yyy');
  });

  test('Tests fields map', () {
    var m = DaktelaQueryMap.build(fields: ['name', 'title']);
    expect(m.length, 2);
    expect(m['fields[0]'], 'name');
    expect(m['fields[1]'], 'title');

    m = DaktelaQueryMap.build(fields: []);
    expect(m.length, 0);
  });
}
