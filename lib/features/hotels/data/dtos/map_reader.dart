import '../../../../core/error/exceptions.dart';

/// Typed, fail-loud access to a decoded document map.
///
/// Firestore hands back `Map<String, dynamic>`, so every field access is a
/// potential runtime cast error. Routing reads through this reader turns a
/// malformed document into a single [MappingException] that names the offending
/// field, instead of an opaque `TypeError` somewhere deep in a mapper.
extension type MapReader(Map<String, Object?> _source) {
  /// Reads a required value of type [T].
  T require<T extends Object>(String field) {
    final value = _source[field];
    if (value == null) {
      throw MappingException('Required field "$field" is missing.');
    }
    if (value is! T) {
      throw MappingException(
        'Field "$field" should be $T but was ${value.runtimeType}.',
      );
    }
    return value;
  }

  /// Reads an optional value of type [T], returning null when absent.
  T? optional<T extends Object>(String field) {
    final value = _source[field];
    if (value == null) return null;
    if (value is! T) {
      throw MappingException(
        'Field "$field" should be $T but was ${value.runtimeType}.',
      );
    }
    return value;
  }

  /// Reads a value of type [T], falling back to [fallback] when absent.
  T valueOr<T extends Object>(String field, T fallback) =>
      optional<T>(field) ?? fallback;

  String string(String field) => require<String>(field);

  String stringOr(String field, String fallback) =>
      valueOr<String>(field, fallback);

  /// Accepts both `int` and `double`, because Firestore stores whole numbers
  /// as integers even for fields the domain models as doubles.
  double number(String field) {
    final value = require<num>(field);
    return value.toDouble();
  }

  double numberOr(String field, double fallback) {
    final value = optional<num>(field);
    return value?.toDouble() ?? fallback;
  }

  double? numberOrNull(String field) => optional<num>(field)?.toDouble();

  int integer(String field) => require<num>(field).toInt();

  int integerOr(String field, int fallback) =>
      optional<num>(field)?.toInt() ?? fallback;

  int? integerOrNull(String field) => optional<num>(field)?.toInt();

  bool boolean(String field, {bool fallback = false}) =>
      valueOr<bool>(field, fallback);

  /// A nested object, as another reader.
  MapReader object(String field) =>
      MapReader(require<Map<String, Object?>>(field));

  MapReader? objectOrNull(String field) {
    final value = optional<Map<String, Object?>>(field);
    return value == null ? null : MapReader(value);
  }

  /// A list of nested objects, each as a reader.
  List<MapReader> objects(String field) {
    final raw = valueOr<List<Object?>>(field, const []);
    return raw
        .whereType<Map<String, Object?>>()
        .map(MapReader.new)
        .toList(growable: false);
  }

  /// A list of strings, skipping any non-string entries.
  List<String> strings(String field) {
    final raw = valueOr<List<Object?>>(field, const []);
    return raw.whereType<String>().toList(growable: false);
  }

  /// A `{ key: number }` map, used for review category scores.
  Map<String, double> numberMap(String field) {
    final raw = valueOr<Map<String, Object?>>(field, const {});
    return {
      for (final entry in raw.entries)
        if (entry.value is num) entry.key: (entry.value! as num).toDouble(),
    };
  }
}
