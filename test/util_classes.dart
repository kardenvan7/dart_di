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
