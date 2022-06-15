class DaktelaFilter {
  final String logic;
  final List<DaktelaFilterField>? fields;
  final List<DaktelaFilter>? filters;

  DaktelaFilter({required this.logic, this.fields, this.filters});

  factory DaktelaFilter.simple(DaktelaFilterField field) => DaktelaFilter(logic: 'and', fields: [field]);

  factory DaktelaFilter.fromJson(Map<String, dynamic> json) {
    List<DaktelaFilterField> fields = [];
    List<DaktelaFilter> filters = [];
    (json['filters'] as List).forEach((element) {
      Map<String, dynamic> json = element;
      if (json.containsKey('logic')) {
        filters.add(DaktelaFilter.fromJson(json));
      } else {
        fields.add(DaktelaFilterField.fromJson(json));
      }
    });
    return DaktelaFilter(logic: json['logic'] ?? '', fields: fields, filters: filters);
  }
}

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
