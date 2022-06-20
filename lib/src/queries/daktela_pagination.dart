/// Pagination of records
/// [take] defines size of one page
class DaktelaPagination {
  static const _defaultTake = 15;

  final int take;
  int _skip = 0;
  bool _loadedAll = false;

  DaktelaPagination({this.take = _defaultTake});

  /// Sets custom skip value
  set skip(int value) {
    _skip = value.abs();
  }

  /// Sets loadedAll flag
  set loadedAll(bool value) {
    _loadedAll = value;
  }

  /// Moves to the next page
  void next() => _skip += take;

  /// Moves to the previous page
  void back() {
    int value = _skip - take;
    _skip = value >= 0 ? value : 0;
  }

  /// Resets pagination
  void reset() {
    _skip = 0;
    _loadedAll = false;
  }

  int get skip => _skip;

  bool get loadedAll => _loadedAll;
}
