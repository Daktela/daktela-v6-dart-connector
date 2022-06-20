/// Allows to sort records by list of fields ([DaktelaSortField])
/// [fields] - list of atomic sorts contained in filter
class DaktelaSort {
  final List<DaktelaSortField> fields;

  DaktelaSort({required this.fields});

  /// Creates simple [DaktelaSort] that contains only one [DaktelaSortField]
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

/// Atomic part of Daktela's sort.
/// [field] - name of field
/// [direction] - sort direction
class DaktelaSortField {
  final String field;
  final String direction;

  DaktelaSortField({required this.field, required this.direction});

  factory DaktelaSortField.fromJson(Map<String, dynamic> json) => DaktelaSortField(field: json['field'], direction: json['dir'] ?? '');
}
