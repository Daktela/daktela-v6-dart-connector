import 'package:daktela_connector/daktela_connector.dart';
import 'package:test/test.dart';

void main() {
  test('Tests pagination', () {
    var p = DaktelaPagination();
    expect(p.loadedAll, false);
    expect(p.take, 15);
    expect(p.skip, 0);

    p.next();
    expect(p.loadedAll, false);
    expect(p.take, 15);
    expect(p.skip, 15);

    p.loadedAll = true;
    p.next();
    expect(p.loadedAll, true);
    expect(p.take, 15);
    expect(p.skip, 30);

    p.reset();
    expect(p.loadedAll, false);
    expect(p.take, 15);
    expect(p.skip, 0);

    p = DaktelaPagination(take: 18);
    p
      ..next()
      ..next();
    expect(p.skip, 36);

    p.back();
    expect(p.loadedAll, false);
    expect(p.skip, 18);
  });
}
