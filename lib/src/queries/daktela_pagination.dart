class DaktelaPagination {
  static const _defaultTake = 15;

  final int take;
  int _skip = 0;
  bool loadedAll = false;

  DaktelaPagination({this.take = _defaultTake});

  void next() => _skip += take;

  void back() {
    int value = _skip - take;
    _skip = value >= 0 ? value : 0;
  }

  void reset() {
    _skip = 0;
    loadedAll = false;
  }

  int get skip => _skip;
}
