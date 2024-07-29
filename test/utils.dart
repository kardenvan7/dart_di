class SimpleClass {}

class InstantiableClass {
  InstantiableClass(Function callback) {
    callback();
  }
}

class DisposableClass {
  DisposableClass(this._disposeCallback);

  final Function _disposeCallback;

  void dispose() => _disposeCallback();
}

T measure<T>(T Function() callback, String text, {skip = false}) {
  if (skip) return callback();

  final sw = Stopwatch()..start();
  final callbackResult = callback();
  final elapsed = sw.elapsedMicroseconds;
  print('$text: $elapsed');
  sw.stop();
  return callbackResult;
}
