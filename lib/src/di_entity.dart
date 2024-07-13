part of 'di_container.dart';

typedef _FactoryCallback<T> = T Function({dynamic param1, dynamic param2});
typedef _FactoryCallbackAsync<T> = Future<T> Function({
  dynamic param1,
  dynamic param2,
});
typedef _DisposeCallback<T> = FutureOr<void> Function(T);

sealed class DiEntity<T> {
  T get({required Object? param1, required Object? param2});

  Future<T> getAsync({required Object? param1, required Object? param2});
}

abstract interface class Disposable {
  FutureOr<void> dispose();
}

/// Entity for registering singletons
///
final class DiEntitySingleton<T> implements DiEntity<T>, Disposable {
  const DiEntitySingleton(
    this._instance, {
    FutureOr<void> Function(T)? disposer,
  }) : _disposer = disposer;

  final T _instance;
  final _DisposeCallback<T>? _disposer;

  @override
  T get({required Object? param1, required Object? param2}) => _instance;

  @override
  Future<T> getAsync({required Object? param1, required Object? param2}) {
    log(
      'Type $T is registered as singleton so there is no need to retrieve it with "getAsync" method.\n'
      'It is more suitable to use "get" method instead.',
    );
    return Future.sync(() => _instance);
  }

  @override
  FutureOr<void> dispose() => _disposer?.call(_instance);
}

/// Entity for registering factories
///
final class DiEntityFactory<T> implements DiEntity<T> {
  const DiEntityFactory(this._factory);

  final _FactoryCallback<T> _factory;

  @override
  T get({required Object? param1, required Object? param2}) =>
      _factory(param1: param1, param2: param2);

  @override
  Future<T> getAsync({required Object? param1, required Object? param2}) {
    log(
      'Type $T is registered as factory so there is no need to retrieve it with "getAsync" method.\n'
      'It is more suitable to use "get" method instead.',
    );
    return Future.sync(() => get(param1: param1, param2: param2));
  }
}

/// Entity for registering lazy singletons
///
final class DiEntityLazySingleton<T> implements DiEntity<T>, Disposable {
  DiEntityLazySingleton(
    this._factory, {
    FutureOr<void> Function(T)? disposer,
  }) : _disposer = disposer;

  final _FactoryCallback<T> _factory;
  final _DisposeCallback<T>? _disposer;

  T? _instance;
  T _getInstance({required Object? param1, required Object? param2}) {
    return _instance ??= _factory(param1: param1, param2: param2);
  }

  @override
  T get({required Object? param1, required Object? param2}) =>
      _getInstance(param1: param1, param2: param2);

  @override
  Future<T> getAsync({required Object? param1, required Object? param2}) {
    log(
      'Type $T is registered as lazy singleton so there is no need to retrieve it with "getAsync" method.\n'
      'It is more suitable to use "get" method instead.',
    );
    return Future.sync(() => _getInstance(param1: param1, param2: param2));
  }

  @override
  FutureOr<void> dispose() async {
    if (_instance == null) return;
    return _disposer?.call(_instance!);
  }
}

/// Entity for registering asynchronous factories
///
final class DiEntityAsyncFactory<T> implements DiEntity<T> {
  const DiEntityAsyncFactory(this._factory);

  final _FactoryCallbackAsync<T> _factory;

  @override
  T get({required Object? param1, required Object? param2}) => throw Exception(
        'Type $T is registered as asynchronous factory. Use "getAsync" or "maybeGetAsync" to retrieve it.',
      );

  @override
  Future<T> getAsync({required Object? param1, required Object? param2}) =>
      _factory(param1: param1, param2: param2);
}

/// Entity for registering lazy asynchronous singletons
///
final class DiEntityLazyAsyncSingleton<T> implements DiEntity<T>, Disposable {
  DiEntityLazyAsyncSingleton(
    this._factory, {
    FutureOr<void> Function(T)? disposer,
    required bool allowConsequentGetCalls,
  })  : _allowConsequentGetCalls = allowConsequentGetCalls,
        _disposer = disposer;

  final _FactoryCallbackAsync<T> _factory;
  final _DisposeCallback<T>? _disposer;
  final bool _allowConsequentGetCalls;

  T? _instance;
  Future<T> _getInstance({Object? param1, Object? param2}) async {
    return _instance ??= await _factory(param1: param1, param2: param2);
  }

  @override
  T get({Object? param1, Object? param2}) => _allowConsequentGetCalls
      ? _instance ??
          (throw Exception(
            'Type $T is registered as lazy asynchronous singleton and has not been initialized yet.\n'
            'Use "getAsync" or "maybeGetAsync" to initialize and retrieve it.\n'
            'After that you will be able to call it with "get" method.\n',
          ))
      : (throw Exception(
          'Type $T is registered as lazy asynchronous singleton with flag "allowConsequentGetCalls" set to false.\n'
          'Use "getAsync" or "maybeGetAsync" to initialize and retrieve it.\n',
        ));

  @override
  Future<T> getAsync({Object? param1, Object? param2}) =>
      _getInstance(param1: param1, param2: param2);

  @override
  FutureOr<void> dispose() async {
    if (_instance == null) return;
    return _disposer?.call(_instance!);
  }
}
