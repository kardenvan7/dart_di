part of 'di_container.dart';

typedef _FutureOrVoidCallback = FutureOr<void> Function();

final class DiContainerImplCopyParent extends DiContainerImpl
    with DiContainerImplCopyParentMixin {
  DiContainerImplCopyParent(super.name, {super.parent})
      : assert(
          parent == null || parent.isSealed,
          'For a container with inheritance type "copyParent", provided parent must be sealed. '
          'This exception was fired by an assertion in container "$name", provided parent for it is "${parent.name}".',
        ),
        super._(
          initialMap: parent != null ? HashMap.from(parent._entitiesMap) : null,
        );
}

final class DiContainerImplLinkParent extends DiContainerImpl
    with DiContainerImplLinkParentMixin {
  DiContainerImplLinkParent(super.name, {super.parent}) : super._();
}

abstract final class DiContainerImpl implements DiContainer {
  DiContainerImpl._(
    this.name, {
    DiContainerImpl? parent,
    HashMap<Type, DiEntity>? initialMap,
  })  : assert(
          parent == null || !parent.isClosed,
          'Container "$name" received container "${parent.name}" as a parent, '
          'but "${parent.name}" is already closed.',
        ),
        _parent = parent,
        _entitiesMap = initialMap ?? HashMap<Type, DiEntity>();

  factory DiContainerImpl(
    String name, {
    DiInheritanceType? inheritanceType,
    DiContainer? parent,
  }) {
    parent = parent as DiContainerImpl?;

    return switch (inheritanceType ?? DartDiConfig.defaultInheritanceType) {
      DiInheritanceType.copyParent => DiContainerImplCopyParent(
          name,
          parent: parent,
        ),
      DiInheritanceType.linkParent => DiContainerImplLinkParent(
          name,
          parent: parent,
        ),
    };
  }

  @override
  final String name;
  final DiContainerImpl? _parent;
  final HashMap<Type, DiEntity> _entitiesMap;
  final List<_FutureOrVoidCallback> _disposers = [];

  @override
  bool get isSealed => _isSealed;
  bool _isSealed = false;

  @override
  bool get isClosed => _isClosed;
  bool _isClosed = false;

  @override
  List<String> get hierarchy {
    final List<String> nameList = [name];

    _visitAncestors((ancestor) {
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

  bool _isRegisteredInAncestors<T>();

  @override
  void registerFactory<T>(T Function() callback) {
    _registerEntity<T>(
      DiEntityFactory<T>(({param1, param2}) => callback()),
    );
  }

  @override
  void registerFactoryParam<T, P1, P2>(T Function(P1 p1, P2 p2) callback) {
    _registerEntity<T>(
      DiEntityFactory(({param1, param2}) => callback(param1, param2)),
    );
  }

  @override
  void registerSingleton<T>(
    T instance, {
    FutureOr Function(T)? dispose,
  }) {
    final entity = DiEntitySingleton<T>(instance, disposer: dispose);
    _registerEntity<T>(entity);
    if (dispose != null) _addDisposer(entity.dispose);
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
    _registerEntity<T>(entity);
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
    _registerEntity<T>(entity);
    if (dispose != null) _addDisposer(entity.dispose);
  }

  @override
  void registerFactoryAsync<T>(Future<T> Function() callback) {
    _registerEntity<T>(
      DiEntityAsyncFactory<T>(({param1, param2}) => callback()),
    );
  }

  @override
  void registerFactoryAsyncParam<T, P1, P2>(
    Future<T> Function(P1, P2) callback,
  ) {
    _registerEntity<T>(
      DiEntityAsyncFactory<T>(({param1, param2}) => callback(param1, param2)),
    );
  }

  @override
  Future<void> registerSingletonAsync<T>(
    Future<T> Function() callback, {
    FutureOr Function(T p1)? dispose,
  }) async =>
      registerSingleton<T>(await callback(), dispose: dispose);

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
    _registerEntity<T>(entity);
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
    _registerEntity<T>(entity);
    if (dispose != null) _addDisposer(entity.dispose);
  }

  @override
  T get<T>({Object? param1, Object? param2}) {
    return maybeGet<T>() ??
        (throw Exception('Type $T is not found in the provided factories map'));
  }

  @override
  T? maybeGet<T>({Object? param1, Object? param2}) {
    _informIfClosed<T>();
    return _entitiesMap[T]?.get(param1: param1, param2: param2) ??
        _lookUp<T>(param1: param1, param2: param2);
  }

  @override
  Future<T> getAsync<T>({Object? param1, Object? param2}) async {
    return await maybeGetAsync<T>(param1: param1, param2: param2) ??
        (throw Exception('Type $T is not found in the provided factories map'));
  }

  @override
  Future<T>? maybeGetAsync<T>({Object? param1, Object? param2}) {
    _informIfClosed<T>();
    return _entitiesMap[T]?.getAsync(param1: param1, param2: param2)
            as Future<T>? ??
        _lookUpAsync<T>(param1: param1, param2: param2);
  }

  @override
  bool isRegistered<T>() =>
      _entitiesMap.containsKey(T) || _isRegisteredInAncestors<T>();

  @override
  void seal() => _isSealed = true;

  void _visitAncestors(bool Function(DiContainerImpl) callback) {
    DiContainerImpl? currentAncestor = _parent;

    while (currentAncestor != null && callback(currentAncestor)) {
      currentAncestor = currentAncestor._parent;
    }
  }

  void _registerEntity<T>(DiEntity<T> entity) {
    _informIfSealed<T>();
    _entitiesMap[T] = entity;
  }

  void _addDisposer(_FutureOrVoidCallback disposer) {
    _disposers.add(disposer);
  }

  void _informIfClosed<T>() {
    if (isClosed) {
      print(
        'You\'re accessing an entity "$T" via container "$name" which is closed. '
        'This might result in an unexpected behaviour.',
      );
    }
  }

  void _informIfSealed<T>() {
    if (isSealed) {
      print(
        'You\'re registering new entity "$T" in a container "$name" with has already been sealed. '
        'This might result in an unexpected behaniour.',
      );
    }
  }

  Future<void> _disposeAll() =>
      Future.wait(_disposers.reversed.map((value) async => await value()));

  @override
  String toString() {
    return 'DiContainer('
        '$name, '
        'isSealed: $isSealed, '
        'isClosed: $isClosed, '
        'types: [${_entitiesMap.keys.join(', ')}]'
        ')';
  }

  @override
  Future<void> close() async {
    await _disposeAll();
    _disposers.clear();
    _entitiesMap.clear();
    _isClosed = true;
  }
}
