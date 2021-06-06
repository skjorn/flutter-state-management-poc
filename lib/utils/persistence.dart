import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:dartlin/dartlin.dart';

/// OK, this solution sucks. Something better needs to be introduced. Here only
/// to provide something easy-to-use and functional.

class PersistableSerializer<T> {
  dynamic serialize(T value) => value;
  T deserialize(dynamic fromValue) => fromValue as T;
}

class _Item {
  final Rx<dynamic> observable;
  final PersistableSerializer<dynamic> serializer;

  _Item(this.observable, this.serializer);
}

class Persistor {
  final String _containerKey;
  final _items = <String, _Item>{};

  Persistor(this._containerKey);

  Rx<T> persist<T>(String key, T defaultValue, { PersistableSerializer<T>? serializer }) {
    final storage = GetStorage();
    final Map<String, dynamic> container = storage.read(_containerKey) ?? {};
    final resolvedSerializer = serializer ?? PersistableSerializer<T>();

    // Read initial value
    // TODO: Enum (de)serialization is not future-proof, but for the sake of example enough.
    final readValue = tryy(() => resolvedSerializer.deserialize(container[key]));
    final Rx<T> result = (readValue ?? defaultValue).obs;
    _items[key] = _Item(result, resolvedSerializer);

    result.listen((value) {
      // TODO: This probably leaks memory if 'this' is captured in the function.
      // Reference cycle is created: Persistor -> Rx -> subscription -> Persistor via implicit 'this'
      // But Flutter/Dart isn't transparent regarding memory management for captured
      // references. It also doesn't have destructors nor weak references, and its
      // Memory View in DevTools sucks balls. I can't see any instances of my custom
      // classes in snapshots, although they are literally on screen in the running app.
      // And garbage collection doesn't make it any easier. (Disposed things can
      // still be in memory, just not yet collected.)
      // Debugging memory leaks is currently almost impossible for regular people.
      _save(storage, key, resolvedSerializer.serialize(value));
    });

    return result;
  }

  void _save<T>(GetStorage storage, String key, dynamic value) {
    final container = _items.map((key, item) =>
        MapEntry(key, item.serializer.serialize(item.observable.value)));
    // Overwrite the currently observed value to be implementation independent.
    // This way we don't care whether the reactive value has been already exposed
    // to the outside world (i.e. whether .value has been already written to).
    container[key] = value;
    storage.write(_containerKey, container);
  }
}