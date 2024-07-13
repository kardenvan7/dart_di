part of 'di_container.dart';

typedef _AsyncVoidCallback = FutureOr<void> Function();

abstract class DiContainerImpl implements DiContainer {
  DiContainerImpl(this.name);

  @override
  final String name;

  DiContainerImpl? _parent;
  Map<Type, DiEntity> _registeredMap = {};
  final Set<_AsyncVoidCallback> _disposables = {};

  @override
  List<String> get hierarchy {
    final List<String> nameList = [name];

    visitAncestors((ancestor) {
      nameList.add(ancestor.name);
      return true;
    });

    return nameList;
  }

  T? _lookUp<T>({required Object? param1, required Object? param2});

  Future<T>? _lookUpAsync<T>({
    required Object? param1,
    required Object? param2,
  });

  @override
  void registerFactory<T>(T Function() callback) {
    _registerEntity(DiEntityFactory<T>(({param1, param2}) => callback()));
  }

  @override
  void registerFactoryParam<T, P1, P2>(T Function(P1 p1, P2 p2) callback) {
    _registerEntity(
      DiEntityFactory(({param1, param2}) => callback(param1, param2)),
    );
  }

  @override
  void registerLazySingleton<T>(
    T Function() callback, {
    FutureOr Function(T)? dispose,
  }) {
    final entity = DiEntityLazySingleton<T>(
      ({param1, param2}) => callback(),
      disposer: dispose,
    );

    _registerEntity(entity);
    if (dispose != null) _addDisposer(entity.dispose);
  }

  @override
  void registerLazySingletonParam<T, P1, P2>(
    T Function(P1 p1, P2 p2) callback, {
    FutureOr<void> Function(T p1)? dispose,
  }) {
    final entity = DiEntityLazySingleton<T>(
      ({param1, param2}) => callback(param1, param2),
      disposer: dispose,
    );

    _registerEntity(entity);
    if (dispose != null) _addDisposer(entity.dispose);
  }

  @override
  void registerSingleton<T>(
    T instance, {
    FutureOr Function(T)? dispose,
  }) {
    final entity = DiEntitySingleton<T>(instance, disposer: dispose);

    _registerEntity(entity);
    if (dispose != null) _addDisposer(entity.dispose);
  }

  @override
  void registerFactoryAsync<T>(Future<T> Function() callback) {
    _registerEntity(DiEntityAsyncFactory<T>(({param1, param2}) => callback()));
  }

  @override
  void registerFactoryAsyncParam<T, P1, P2>(
    Future<T> Function(P1, P2) callback,
  ) {
    _registerEntity(
      DiEntityAsyncFactory<T>(({param1, param2}) => callback(param1, param2)),
    );
  }

  @override
  Future<void> registerSingletonAsync<T>(
    Future<T> Function() callback, {
    FutureOr Function(T)? dispose,
  }) async {
    final instance = await callback();

    registerSingleton(instance, dispose: dispose);
  }

  @override
  void registerLazySingletonAsync<T>(
    Future<T> Function() callback, {
    FutureOr<void> Function(T)? dispose,
    bool allowConsequentGetCalls = true,
  }) {
    final entity = DiEntityLazyAsyncSingleton<T>(
      ({param1, param2}) => callback(),
      disposer: dispose,
      allowConsequentGetCalls: allowConsequentGetCalls,
    );

    _registerEntity(entity);
    if (dispose != null) _addDisposer(entity.dispose);
  }

  @override
  void registerLazySingletonAsyncParam<T, P1, P2>(
    Future<T> Function(P1, P2) callback, {
    FutureOr<void> Function(T)? dispose,
    bool allowConsequentGetCalls = true,
  }) {
    final entity = DiEntityLazyAsyncSingleton<T>(
      ({param1, param2}) => callback(param1, param2),
      disposer: dispose,
      allowConsequentGetCalls: allowConsequentGetCalls,
    );

    _registerEntity(entity);
    if (dispose != null) _addDisposer(entity.dispose);
  }

  @override
  T get<T>({Object? param1, Object? param2}) {
    return maybeGet<T>() ??
        (throw Exception('Type $T is not found in the provided factories map'));
  }

  @override
  T? maybeGet<T>({Object? param1, Object? param2}) {
    return _registeredMap[T]?.get(param1: param1, param2: param2) as T? ??
        _lookUp<T>(param1: param1, param2: param2);
  }

  @override
  Future<T> getAsync<T>({Object? param1, Object? param2}) async {
    return await maybeGetAsync<T>(param1: param1, param2: param2) ??
        (throw Exception('Type $T is not found in the provided factories map'));
  }

  @override
  Future<T>? maybeGetAsync<T>({Object? param1, Object? param2}) {
    return _registeredMap[T]?.getAsync(param1: param1, param2: param2)
            as Future<T>? ??
        _lookUpAsync<T>(param1: param1, param2: param2);
  }

  @override
  bool isRegistered<T>() =>
      _registeredMap.containsKey(T) || _isRegisteredInAncestors<T>();

  @override
  void setParent(covariant DiContainerImpl? container);

  void visitAncestors(bool Function(DiContainerImpl) callback) {
    DiContainerImpl? currentAncestor = _parent;

    while (currentAncestor != null && callback(currentAncestor)) {
      currentAncestor = currentAncestor._parent;
    }
  }

  bool _isRegisteredInAncestors<T>();

  Future<void> _disposeAll() =>
      Future.wait(_disposables.map((value) async => await value()));

  void _registerEntity<T>(DiEntity<T> entity) {
    _registeredMap[T] = entity;
  }

  void _addDisposer(_AsyncVoidCallback disposer) {
    _disposables.add(disposer);
  }

  @override
  Future<void> close() async {
    await _disposeAll();
    _disposables.clear();
    _registeredMap.clear();
  }
}

final class DiContainerImplCopyParent extends DiContainerImpl
    with DiContainerImplCopyParentMixin {
  DiContainerImplCopyParent(super.name);
}

final class DiContainerImplLinkParent extends DiContainerImpl
    with DiContainerImplLinkParentMixin {
  DiContainerImplLinkParent(super.name);
}

final class DiContainerImplIgnoreParent extends DiContainerImpl
    with DiContainerImplIgnoreParentMixin {
  DiContainerImplIgnoreParent(super.name);
}
