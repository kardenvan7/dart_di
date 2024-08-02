part of 'di_container.dart';

typedef _VoidCallback = void Function();
typedef _FutureOrVoidCallback = FutureOr<void> Function();

final class DiContainerAsyncImplCopyParent extends DiContainerAsyncImpl
    with DiContainerBaseCopyParentMixin {
  DiContainerAsyncImplCopyParent(super.name, {super.parent}) : super._();
}

final class DiContainerAsyncImplLinkParent extends DiContainerAsyncImpl
    with DiContainerBaseLinkParentMixin {
  DiContainerAsyncImplLinkParent(super.name, {super.parent}) : super._();
}

final class DiContainerImplCopyParent extends DiContainerImpl
    with DiContainerBaseCopyParentMixin {
  DiContainerImplCopyParent(super.name, {super.parent}) : super._();
}

final class DiContainerImplLinkParent extends DiContainerImpl
    with DiContainerBaseLinkParentMixin {
  DiContainerImplLinkParent(super.name, {super.parent}) : super._();
}

abstract final class DiContainerAsyncImpl extends DiContainerBaseImpl
    implements DiContainerAsync {
  DiContainerAsyncImpl._(
    super.name, {
    super.parent,
  });

  factory DiContainerAsyncImpl(
    String name, {
    DiInheritanceType? inheritanceType,
    DiContainerBase? parent,
  }) {
    return switch (inheritanceType ?? DartDiConfig.defaultInheritanceType) {
      DiInheritanceType.copyParent => DiContainerAsyncImplCopyParent(
          name,
          parent: parent,
        ),
      DiInheritanceType.linkParent => DiContainerAsyncImplLinkParent(
          name,
          parent: parent,
        ),
    };
  }

  @override
  final List<_FutureOrVoidCallback> _registrationCallbacks = [];

  @override
  Future<void> initialize() async {
    _onInitializationStart();

    try {
      for (final callback in _registrationCallbacks) {
        await callback();
      }
      _isInitialized = true;
    } catch (_, __) {
      _entitiesMap.clear();
      _disposers.clear();
    } finally {
      _registrationCallbacks.clear();
    }
  }

  @override
  void registerSingletonAsync<T>(
    Future<T> Function() callback, {
    FutureOr Function(T p1)? dispose,
  }) {
    _addRegistration(() async {
      final instance = await callback();
      final entity = DiEntitySingleton<T>(instance, disposer: dispose);
      if (dispose != null) _addDisposer(entity.dispose);
      _registerEntity<T>(entity);
    });
  }
}

abstract final class DiContainerImpl extends DiContainerBaseImpl
    implements DiContainer {
  DiContainerImpl._(
    super.name, {
    super.parent,
  });

  factory DiContainerImpl(
    String name, {
    DiInheritanceType? inheritanceType,
    DiContainerBase? parent,
  }) {
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
  final List<_VoidCallback> _registrationCallbacks = [];

  @override
  void initialize() {
    _onInitializationStart();

    try {
      for (final callback in _registrationCallbacks) {
        callback();
      }
      _isInitialized = true;
    } catch (_, __) {
      _entitiesMap.clear();
      _disposers.clear();
    } finally {
      _registrationCallbacks.clear();
    }
  }
}

abstract final class DiContainerBaseImpl implements DiContainerBase {
  DiContainerBaseImpl(
    this.name, {
    DiContainerBase? parent,
  })  : assert(
          parent == null || !parent.isClosed,
          'Container "$name" received container "${parent.name}" as a parent, '
          'but "${parent.name}" is already closed.',
        ),
        _parent = parent;

  /// A container's name. Useful for debugging purposes.
  ///
  @override
  final String name;
  @override
  final DiContainerBase? _parent;
  @override
  final HashMap<Type, DiEntity> _entitiesMap = HashMap<Type, DiEntity>();
  final List<_FutureOrVoidCallback> _disposers = [];

  @override
  bool get isInitialized => _isInitialized;
  bool _isInitialized = false;

  @override
  bool get isSealed => isInitialized;
  set _isSealed(bool value) => _isInitialized = value;

  @override
  bool get isClosed => _isClosed;
  bool _isClosed = false;

  List<_VoidCallback> get _registrationCallbacks;

  @override
  List<String> get hierarchy {
    final List<String> nameList = [name];

    _visitAncestors((ancestor) {
      nameList.add(ancestor.name);
      return true;
    });

    return nameList;
  }

  void _onInitializationStart();

  @override
  void registerFactory<T>(T Function() callback) {
    _addRegistration(
      () => _registerEntity<T>(
        DiEntityFactory<T>(({param1, param2}) => callback()),
      ),
    );
  }

  @override
  void registerFactoryParam<T, P1, P2>(T Function(P1 p1, P2 p2) callback) {
    _addRegistration(
      () => _registerEntity<T>(
        DiEntityFactory(({param1, param2}) => callback(param1, param2)),
      ),
    );
  }

  @override
  void registerLazySingleton<T>(
    T Function() callback, {
    FutureOr Function(T)? dispose,
  }) {
    _addRegistration(() {
      final entity = DiEntityLazySingleton<T>(
        ({param1, param2}) => callback(),
        disposer: dispose,
      );
      if (dispose != null) _addDisposer(entity.dispose);
      _registerEntity<T>(entity);
    });
  }

  @override
  void registerLazySingletonParam<T, P1, P2>(
    T Function(P1 p1, P2 p2) callback, {
    FutureOr<void> Function(T p1)? dispose,
  }) {
    _addRegistration(() {
      final entity = DiEntityLazySingleton<T>(
        ({param1, param2}) => callback(param1, param2),
        disposer: dispose,
      );
      if (dispose != null) _addDisposer(entity.dispose);
      _registerEntity<T>(entity);
    });
  }

  @override
  void registerSingleton<T>(
    T Function() callback, {
    FutureOr Function(T)? dispose,
  }) {
    _addRegistration(() {
      final entity = DiEntitySingleton<T>(callback(), disposer: dispose);
      if (dispose != null) _addDisposer(entity.dispose);
      _registerEntity<T>(entity);
    });
  }

  @override
  void registerFactoryAsync<T>(Future<T> Function() callback) {
    _addRegistration(
      () => _registerEntity<T>(
        DiEntityAsyncFactory<T>(({param1, param2}) => callback()),
      ),
    );
  }

  @override
  void registerFactoryAsyncParam<T, P1, P2>(
    Future<T> Function(P1, P2) callback,
  ) {
    _addRegistration(
      () => _registerEntity<T>(
        DiEntityAsyncFactory<T>(({param1, param2}) => callback(param1, param2)),
      ),
    );
  }

  @override
  void registerLazySingletonAsync<T>(
    Future<T> Function() callback, {
    FutureOr<void> Function(T)? dispose,
    bool allowConsequentGetCalls = true,
  }) {
    _addRegistration(() {
      final entity = DiEntityLazyAsyncSingleton<T>(
        ({param1, param2}) => callback(),
        disposer: dispose,
        allowConsequentGetCalls: allowConsequentGetCalls,
      );
      if (dispose != null) _addDisposer(entity.dispose);
      _registerEntity<T>(entity);
    });
  }

  @override
  void registerLazySingletonAsyncParam<T, P1, P2>(
    Future<T> Function(P1, P2) callback, {
    FutureOr<void> Function(T)? dispose,
    bool allowConsequentGetCalls = true,
  }) {
    _addRegistration(() {
      final entity = DiEntityLazyAsyncSingleton<T>(
        ({param1, param2}) => callback(param1, param2),
        disposer: dispose,
        allowConsequentGetCalls: allowConsequentGetCalls,
      );
      if (dispose != null) _addDisposer(entity.dispose);
      _registerEntity<T>(entity);
    });
  }

  @override
  T get<T>({Object? param1, Object? param2}) {
    return maybeGet<T>() ??
        (throw Exception('Type $T is not found in the provided factories map'));
  }

  @override
  T? maybeGet<T>({Object? param1, Object? param2}) {
    _informIfClosed();
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
    _informIfClosed();
    return _entitiesMap[T]?.getAsync(param1: param1, param2: param2)
            as Future<T>? ??
        _lookUpAsync<T>(param1: param1, param2: param2);
  }

  @override
  bool isRegistered<T>() {
    _informIfClosed();
    return _entitiesMap.containsKey(T) || _isRegisteredInAncestors<T>();
  }

  @override
  void _seal() {
    // Not checking for "isSealed" since now it's implementation is equals to "isInitialized"
    if (!isInitialized) {
      print(
        'DiContainer "$name" has been sealed, but never initialized. '
        'Probably, you forgot to initialize it prior to setting it as a parent '
        'for a container with inheritance type "copyParent".',
      );
      _isSealed = true;
    }
  }

  void _visitAncestors(bool Function(DiContainerBase) callback) {
    DiContainerBase? currentAncestor = _parent;

    while (currentAncestor != null && callback(currentAncestor)) {
      currentAncestor = currentAncestor._parent;
    }
  }

  void _addRegistration(_VoidCallback registrationCallback) {
    assert(
      !isSealed && !isClosed,
      'Container "$name" has already been ${isClosed ? 'closed' : 'sealed'}, '
      'therefore no further registrations are allowed.',
    );
    _registrationCallbacks.add(registrationCallback);
  }

  void _registerEntity<T>(DiEntity<T> entity) => _entitiesMap[T] = entity;

  void _addDisposer(_FutureOrVoidCallback disposer) {
    _disposers.add(disposer);
  }

  void _informIfClosed() {
    if (isClosed) {
      print(
        'You\'re accessing an entity via container "$name" which is closed. '
        'This might result in an unexpected behaviour.',
      );
    }
  }

  Future<void> _disposeAll() async {
    for (final disposer in _disposers.reversed) {
      await disposer();
      _disposers.removeLast();
    }
  }

  @override
  String toString() {
    return 'DiContainer('
        '$name, '
        'inheritanceType: linkParent, '
        'isInitialized: $isInitialized, '
        'isSealed: $isSealed, '
        'isClosed: $isClosed, '
        'types: [${_entitiesMap.keys.join(', ')}]'
        ')';
  }

  @override
  Future<void> close() async {
    await _disposeAll();
    _registrationCallbacks.clear();
    _entitiesMap.clear();
    _isClosed = true;
  }
}
