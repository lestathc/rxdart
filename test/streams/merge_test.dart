import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

List<Stream<num>> _getStreams() {
  Stream<num> a = new Stream<num>.periodic(
      const Duration(milliseconds: 1), (num count) => count).take(3);
  Stream<num> b = new Stream<num>.fromIterable(const <num>[1, 2, 3, 4]);

  return <Stream<num>>[a, b];
}

void main() {
  test('rx.Observable.merge', () async {
    const List<num> expectedOutput = const <num>[1, 2, 3, 4, 0, 1, 2];
    int count = 0;

    Stream<num> observable = new Observable<num>.merge(_getStreams());

    observable.listen(expectAsync1((num result) {
      // test to see if the combined output matches
      expect(result, expectedOutput[count++]);
    }, count: expectedOutput.length));
  });

  test('rx.Observable.merge.asBroadcastStream', () async {
    Stream<num> observable =
        new Observable<num>.merge(_getStreams()).asBroadcastStream();

    // listen twice on same stream
    observable.listen((_) {});
    observable.listen((_) {});
    // code should reach here
    expect(observable.isBroadcast, isTrue);
  });

  test('rx.Observable.merge.error.shouldThrow', () async {
    Stream<num> observableWithError = new Observable<num>.merge(
        _getStreams()..add(new ErrorStream<num>(new Exception())));

    observableWithError.listen(null, onError: (dynamic e, dynamic s) {
      expect(e, isException);
    });
  });

  test('rx.Observable.merge does not deal properly', () async {
    // This will fail:
    // const list<num> expectedOutput = const <num> [1, 2, 3, 4, 5, 6];
    const list<num> expectedOutput = const <num> [1, 4, 2, 5, 3, 6];

    StreamController<num> sc1 = new StreamController<num>();
    StreamController<num> sc2 = new StreamController<num>();

    int count = 0;
    Stream<num> observable = new Observable<num>.merge([sc1.stream, sc2.stream]);

    observable.listen(expectAsync1((num result) {
      // test to see if the combined output matches
      expect(result, expectedOutput[count++]);
    }, count: expectedOutput.length));

    sc1.add(1);
    sc1.add(2);
    sc1.add(3);
    sc2.add(4);
    sc2.add(5);
    sc2.add(6);
  });
}
