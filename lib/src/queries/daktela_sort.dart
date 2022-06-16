class DaktelaSort {
  final List<DaktelaSortField> fields;

  DaktelaSort({required this.fields});

  factory DaktelaSort.simple(DaktelaSortField field) => DaktelaSort(fields: [field]);

  factory DaktelaSort.fromJson(dynamic json) {
    List<DaktelaSortField> fields;
    if (json is List) {
      fields = json.map((e) {
        return DaktelaSortField.fromJson(e);
      }).toList();
    } else {
      fields = [DaktelaSortField.fromJson(json)];
    }
    return DaktelaSort(fields: fields);
  }
}

class DaktelaSortField {
  final String field;
  final String direction;

  DaktelaSortField({required this.field, required this.direction});

  factory DaktelaSortField.fromJson(Map<String, dynamic> json) => DaktelaSortField(field: json['field'], direction: json['dir'] ?? '');
}
