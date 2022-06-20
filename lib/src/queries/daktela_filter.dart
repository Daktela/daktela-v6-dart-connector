/// Allows to filter records by lists of type [DaktelaFilterField] and [DaktelaFilter]
/// [logic] - logic operator of filter
/// [fields] - list of atomic fields contained in filter
/// [filters] - list of sub-filters
class DaktelaFilter {
  final String logic;
  final List<DaktelaFilterField>? fields;
  final List<DaktelaFilter>? filters;

  DaktelaFilter({this.logic = 'and', this.fields, this.filters});

  /// Creates simple [DaktelaFilter] that contains only one [DaktelaFilterField]
  factory DaktelaFilter.simple(DaktelaFilterField field) => DaktelaFilter(logic: 'and', fields: [field]);

  factory DaktelaFilter.fromJson(dynamic json) {
    List<DaktelaFilterField> fields = [];
    List<DaktelaFilter> filters = [];
    String logic = 'and';
    if (json is List) {
      json.forEach((e) {
        try {
          fields.add(DaktelaFilterField.fromJson(e));
        } catch (e) {}
      });
    } else if (json is Map<String, dynamic>) {
      if (json['logic'] != null) {
        logic = json['logic'];
        (json['filters'] as List).forEach((element) {
          Map<String, dynamic> json = element;
          if (json['logic'] != null) {
            filters.add(DaktelaFilter.fromJson(json));
          } else {
            fields.add(DaktelaFilterField.fromJson(json));
          }
        });
      } else {
        fields.add(DaktelaFilterField.fromJson(json));
      }
    }
    return DaktelaFilter(logic: logic, fields: fields, filters: filters);
  }
}

/// Atomic part of Daktela's filter.
/// [field] - name of field
/// [operator] - filter operator
/// [value] - expected value
/// [ignoreCase] - optional flag for case sensitive filtering
class DaktelaFilterField {
  final String field;
  final String operator;
  final List<String>? value;
  final bool ignoreCase;

  DaktelaFilterField({required this.field, required this.operator, this.value, this.ignoreCase = false});

  factory DaktelaFilterField.fromJson(Map<String, dynamic> json) {
    String ignoreCase = (json['ignoreCase'] ?? '').toString().toLowerCase();
    return DaktelaFilterField(
      field: json['field'],
      operator: json['operator'] ?? '',
      value: json['value'] != null ? (json['value'] is List ? (json['value'] as List).map((e) => e as String).toList() : [json['value']]) : null,
      ignoreCase: ignoreCase == 'true' || ignoreCase == '1',
    );
  }
}
