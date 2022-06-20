import 'package:daktela_connector/src/queries/daktela_filter.dart';
import 'package:daktela_connector/src/queries/daktela_pagination.dart';
import 'package:daktela_connector/src/queries/daktela_sort.dart';

/// Extension of Map<String, dynamic> that allows to create Daktela API query map
extension DaktelaQueryMap on Map<String, dynamic> {
  void _enrichWithFilter(DaktelaFilter filter) {
    this['filter[logic]'] = filter.logic;
    _prepareFilters(filter).forEach((key, value) {
      this['filter$key'] = value;
    });
  }

  Map<String, String> _prepareFilters(DaktelaFilter filter) {
    Map<String, String> result = {};
    int index = 0;
    filter.fields?.forEach((element) {
      result[_buildFilterParamKey(index, 'field')] = element.field;
      result[_buildFilterParamKey(index, 'operator')] = element.operator;
      if (element.value != null) {
        if (element.value!.length == 1 && !['in', 'notin'].contains(element.operator)) {
          result[_buildFilterParamKey(index, 'value')] = element.value!.first;
        } else {
          element.value!.asMap().forEach((innerIndex, value) {
            result['${_buildFilterParamKey(index, 'value')}[$innerIndex]'] = value;
          });
        }
      } else {
        result[_buildFilterParamKey(index, 'value')] = '';
      }
      if (element.ignoreCase) {
        result[_buildFilterParamKey(index, 'ignoreCase')] = 'true';
      }
      index++;
    });
    filter.filters?.forEach((element) {
      result[_buildFilterParamKey(index, 'logic')] = element.logic;
      _prepareFilters(element).forEach((key, value) {
        result['[filters][$index]$key'] = value;
      });
      index++;
    });
    return result;
  }

  String _buildFilterParamKey(int index, String name) {
    return '[filters][$index][$name]';
  }

  void _enrichWithSort(DaktelaSort sort) {
    sort.fields.asMap().forEach((index, value) {
      this['sort[$index][field]'] = value.field;
      this['sort[$index][dir]'] = value.direction;
    });
  }

  void _enrichWithPagination(DaktelaPagination pagination) {
    this['skip'] = '${pagination.skip}';
    this['take'] = '${pagination.take}';
  }

  void enrichWithSearch(String search) {
    this['q'] = search;
  }

  void _enrichWithFields(List<String> fields) {
    fields.asMap().forEach((index, value) {
      this['fields[$index]'] = value;
    });
  }

  /// Builds query map for HTTP requests
  /// [filter] instance of [DaktelaFilter]
  /// [sort] instance of [DaktelaSort]
  /// [pagination] instance of [DaktelaPagination]
  /// [search] adds 'q' parameter with given value to the map (typically used with endpoints that support full text search)
  /// [fields] only fields with given name will be returned
  static Map<String, dynamic> build({DaktelaFilter? filter, DaktelaSort? sort, DaktelaPagination? pagination, String? search, List<String>? fields}) {
    Map<String, dynamic> map = {};
    if (filter != null) {
      map._enrichWithFilter(filter);
    }
    if (sort != null) {
      map._enrichWithSort(sort);
    }
    if (pagination != null) {
      map._enrichWithPagination(pagination);
    }
    if (search?.isNotEmpty ?? false) {
      map.enrichWithSearch(search!);
    }
    if (fields?.isNotEmpty ?? false) {
      map._enrichWithFields(fields!);
    }
    return map;
  }
}
