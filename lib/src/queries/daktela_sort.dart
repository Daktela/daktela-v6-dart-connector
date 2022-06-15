class DaktelaSort {
  final List<SortField> fields;

  DaktelaSort({required this.fields});

  factory DaktelaSort.simple(SortField field) => DaktelaSort(fields: [field]);

  factory DaktelaSort.fromJson(dynamic json) {
    List<SortField> fields;
    if (json is List) {
      fields = json.map((e) {
        return SortField.fromJson(e);
      }).toList();
    } else {
      fields = [SortField.fromJson(json)];
    }
    return DaktelaSort(fields: fields);
  }
}

class SortField {
  final String field;
  final String direction;

  SortField({required this.field, required this.direction});

  factory SortField.fromJson(Map<String, dynamic> json) => SortField(field: json['field'], direction: json['dir'] ?? '');
}
