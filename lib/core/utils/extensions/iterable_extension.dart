import 'package:collection/collection.dart' show DeepCollectionEquality, ListEquality;

extension XIterable<E> on Iterable<E> {
  Map<K, List<E>> groupBy<K>(K Function(E) keyFunction) => fold(
        <K, List<E>>{},
        (Map<K, List<E>> map, E element) =>
            map..putIfAbsent(keyFunction(element), () => <E>[]).add(element),
      );

  bool isEqual(Iterable list, {bool deep = true}) {
    Function equal = deep
        ? const DeepCollectionEquality.unordered().equals
        : const ListEquality().equals;

    return equal(this, list);
  }
}
