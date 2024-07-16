part of 'di_container.dart';

typedef _VoidCallback = void Function();
typedef _FutureOrVoidCallback = FutureOr<void> Function();

final class DiContainerAsyncImplCopyParent extends DiContainerAsyncImpl
    with DiContainerBaseCopyParentMixin {
  DiContainerAsyncImplCopyParent(super.name, {super.parent})
      : super._(
          initialMap: parent == null ? null : {...parent._registeredMap},
        ) {
    _parent?._seal();
  }
}

final class DiContainerAsyncImplLinkParent extends DiContainerAsyncImpl
    with DiContainerBaseLinkParentMixin {
  DiContainerAsyncImplLinkParent(super.name, {super.parent}) : super._();
}

final class DiContainerImplCopyParent extends DiContainerImpl
    with DiContainerBaseCopyParentMixin {
  DiContainerImplCopyParent(super.name, {super.parent})
      : super._(
          initialMap: parent == null ? null : {...parent._registeredMap},
        ) {
    _parent?._seal();
  }
}

final class DiContainerImplLinkParent extends DiContainerImpl
    with DiContainerBaseLinkParentMixin {
  DiContainerImplLinkParent(super.name, {super.parent}) : super._();
}

sealed class DiContainerAsyncImpl extends DiContainerBase
    implements DiContainerAsync {
  DiContainerAsyncImpl._(
    super.name, {
    super.parent,
    super.initialMap,
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
    try {
      for (final callback in _registrationCallbacks) {
        await callback();
      }
      _isInitialized = true;
    } catch (_, __) {
      _registeredMap.clear();
      _disposables.clear();
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

sealed class DiContainerImpl extends DiContainerBase implements DiContainer {
  DiContainerImpl._(
    super.name, {
    super.parent,
    super.initialMap,
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
    try {
      for (final callback in _registrationCallbacks) {
        callback();
      }
      _isInitialized = true;
    } catch (_, __) {
      _registeredMap.clear();
      _disposables.clear();
    } finally {
      _registrationCallbacks.clear();
    }
  }
}

abstract base class DiContainerBase implements DiRegistrar, DiRetriever {
  DiContainerBase(
    this.name, {
    DiContainerBase? parent,
    Map<Type, DiEntity>? initialMap,
  })  : _parent = parent,
        _registeredMap = initialMap ?? {};

  /// A container's name. Useful for debugging purposes.
  ///
  final String name;
  final DiContainerBase? _parent;
  final Map<Type, DiEntity> _registeredMap;
  final Set<_FutureOrVoidCallback> _disposables = {};

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  List<_VoidCallback> get _registrationCallbacks;

  /// A list of names of all containers starting from this one up to the top.
  ///
  /// Useful for debugging purposes.
  ///
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
    _addRegistration(
      () => _registerEntity<T>(
          DiEntityFactory<T>(({param1, param2}) => callback())),
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
    T instance, {
    FutureOr Function(T)? dispose,
  }) {
    _addRegistration(() {
      final entity = DiEntitySingleton<T>(instance, disposer: dispose);
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

  void _seal() {
    if (!_isInitialized) {
      log(
        'DiContainer "$name" has been sealed, but never initialized. '
        'Probably, you forgot to initialize it prior to setting it as a parent '
        'for another container with inheritance type "copyParent".',
      );
      _isInitialized = true;
    }
  }

  void visitAncestors(bool Function(DiContainerBase) callback) {
    DiContainerBase? currentAncestor = _parent;

    while (currentAncestor != null && callback(currentAncestor)) {
      currentAncestor = currentAncestor._parent;
    }
  }

  bool _isRegisteredInAncestors<T>();

  void _addRegistration(_VoidCallback registrationCallback) {
    assert(
      !_isInitialized,
      'Container "$name" has already been sealed, therefore no further registrations are allowed.',
    );
    _registrationCallbacks.add(registrationCallback);
  }

  void _addDisposer(_FutureOrVoidCallback disposer) {
    _disposables.add(disposer);
  }

  void _registerEntity<T>(DiEntity<T> entity) => _registeredMap[T] = entity;

  Future<void> _disposeAll() =>
      Future.wait(_disposables.map((value) async => await value()));

  /// Releases resources and erases registered entities inside of the container.
  ///
  Future<void> close() async {
    await _disposeAll();
    _registrationCallbacks.clear();
    _disposables.clear();
    _registeredMap.clear();
  }
}
