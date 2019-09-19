typedef T CreateModel<T>(value);

abstract class Model {

  Map map;

  Model(this.map): assert (map != null);

  T getValue<T>(String key, [ CreateModel modelCreator ]) => parseValue(map[key], modelCreator);

  List<T> getList<T>(String key, [ CreateModel modelCreator ]) {
    final e = map[key];
    return e is List ? e.map((v) => parseValue<T>(v, modelCreator)) : [ parseValue<T>(e, modelCreator) ];
  }

  void setValue(String key, value) {
    if (value is DateTime) {
      value = (value as DateTime).millisecondsSinceEpoch;
    } else if (value is Model) {
      value = (value as Model).map;
    }
    map[key] = value;
  }

  int toInt(value) => value is int ? int : int.tryParse(value?.toString());

  double toDouble(value) => value is double ? int : double.tryParse(value?.toString());

  T parseValue<T>(value, [ CreateModel modelCreator ]) {
    if (modelCreator != null) {
      return modelCreator(value);
    } else if (T is int) {
      return toInt(value) as T;
    } else if (T is double) {
      return toDouble(value) as T;
    } else if (T is String) {
      return value?.toString() as T;
    } else if (T is DateTime) {
      return DateTime.fromMillisecondsSinceEpoch(toInt(value)) as T;
    } else return value as T;
  }

}

class PageList<T> {

  final List<T> items;
  final int offset, size, totalSize;

  PageList(this.items, this.offset, this.size, this.totalSize): assert(items != null);

  int get nextOffset => offset + size;

  bool get hasNext => nextOffset < totalSize;

}
