import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test('rx.Observable.any', () async {
    final bool actual =
        await new Observable<int>.just(1).any((int val) => val == 1);

    expect(actual, true);
  });
}
