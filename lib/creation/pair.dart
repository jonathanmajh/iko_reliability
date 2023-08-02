//@author Pranav Bommireddipalli (iko's #1 employee 💯💯💯)
///A class that stores two objects of different types
///
///Declaration:
///```dart
///   Pair pair = Pair<String, int>('Hello', 5);
///```
///Usage:
///```dart
///   String y = pair[0]; //Hello
///   int x = pair[1]; //5
///   pair[0] = 'World';
///```
///OR
///```dart
///   String y = pair.first; //Hello
///   int x = pair.second; //5
///   pair.second = 10;
///```
class Pair<T1, T2> {
  T1 _a;
  T2 _b;

  Pair(this._a, this._b);

  ///Gets the first object in the pair
  get first => _a;

  ///Gets the second object in the pair
  get second => _b;

  ///Sets the first object in the pair
  set first(a) {
    _a = a;
  }

  ///Sets the second object in the pair
  set second(b) {
    _b = b;
  }

  ///gets the object stored at the given index. Index must be 0 or 1.
  dynamic operator [](int index) {
    if (index == 0) {
      return _a;
    } else if (index == 1) {
      return _b;
    } else {
      throw ArgumentError('Index out of bounds! Index must be 0 or 1');
    }
  }

  ///sets the object at the given index to the new value. Index must be 0 or 1.
  void operator []=(int index, dynamic value) {
    if (index == 0) {
      if (value is! T1) {
        throw ArgumentError(
            'Type mismatch! Assignment of type ${value.runtimeType} to type $T1');
      }
      _a = value;
    } else if (index == 1) {
      if (value is! T2) {
        throw ArgumentError(
            'Type mismatch! Assignment of type ${value.runtimeType} to type $T2');
      }

      _b = value;
    } else {
      throw 'Index out of bounds';
    }
  }

  @override
  String toString() {
    return '[${_a.toString()}, ${_b.toString()}]';
  }

  ///Returns a [List] representation of the [Pair]
  List<dynamic> toList() {
    return [_a, _b];
  }
}
