part of 'di_container.dart';

final class DiContainerNonInh implements DiContainerBase, DiRegistrarAsync {
  DiContainerNonInh(
    this.name, {
    DiInheritanceType? inheritanceType,
    DiContainerBase? parent,
  })  : assert(
          parent == null || !parent.isClosed,
          'Container "$name" received container "${parent.name}" as a parent, '
          'but "${parent.name}" is already closed.',
        ),
        inheritanceType =
            inheritanceType ?? DartDiConfig.defaultInheritanceType,
        _parent = parent;

  @override
  final String name;
  @override
  final DiContainerBase? _parent;
  @override
  final DiInheritanceType inheritanceType;
  @override
  final HashMap<Type, DiEntity> _entitiesMap = HashMap<Type, DiEntity>();
  final List<_FutureOrVoidCallback> _disposables = [];
  final List<_FutureOrVoidCallback> _registrationCallbacks = [];

  @override
  bool get isInitialized => _isInitialized;
  bool _isInitialized = false;

  @override
  bool get isSealed => isInitialized;
  set _isSealed(bool value) => _isInitialized = value;

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

  @override
  T? _lookUp<T>({required Object? param1, required Object? param2}) {
    return switch (inheritanceType) {
      DiInheritanceType.linkParent =>
        _parent?.maybeGet<T>(param1: param1, param2: param2),
      DiInheritanceType.copyParent =>
        _parent?._lookUp<T>(param1: param1, param2: param2),
    };
  }

  @override
  Future<T>? _lookUpAsync<T>({
    required Object? param1,
    required Object? param2,
  }) {
    return switch (inheritanceType) {
      DiInheritanceType.linkParent =>
        _parent?.maybeGetAsync<T>(param1: param1, param2: param2),
      DiInheritanceType.copyParent =>
        _parent?._lookUpAsync<T>(param1: param1, param2: param2),
    };
  }

  void initialize() {
    _onInitializationStart();

    try {
      for (final callback in _registrationCallbacks) {
        callback();
      }
      _isInitialized = true;
    } catch (_, __) {
      _entitiesMap.clear();
      _disposables.clear();
    } finally {
      _registrationCallbacks.clear();
    }
  }

  Future<void> initializeAsync() async {
    _onInitializationStart();

    try {
      for (final callback in _registrationCallbacks) {
        await callback();
      }
      _isInitialized = true;
    } catch (_, __) {
      _entitiesMap.clear();
      _disposables.clear();
    } finally {
      _registrationCallbacks.clear();
    }
  }

  void _onInitializationStart() {
    switch (inheritanceType) {
      case DiInheritanceType.linkParent:
        if (_parent != null && !_parent!.isInitialized) {
          print(
            'Container "name" is being initialized, but it\'s parent ${_parent!.name} it not initilized. '
            'It is advised to initialize parent containers prior to their children to avoid potential bugs.',
          );
        }
        break;
      case DiInheritanceType.copyParent:
        if (_parent != null) {
          _parent!._seal();
          _entitiesMap.addAll(_parent!._entitiesMap);
        }
        break;
    }
  }

  @override
  bool _isRegisteredInAncestors<T>() {
    switch (inheritanceType) {
      case DiInheritanceType.linkParent:
        return _parent?.isRegistered<T>() ?? false;
      case DiInheritanceType.copyParent:
        _assertInitialization();
        return _getFirstNonCopyAncestor()?._isRegisteredInAncestors<T>() ??
            false;
    }
  }

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

  @override
  T get<T>({Object? param1, Object? param2}) {
    return maybeGet<T>() ??
        (throw Exception(
          'Type $T is not found in the provided factories map',
        ));
  }

  @override
  T? maybeGet<T>({Object? param1, Object? param2}) {
    if (inheritanceType == DiInheritanceType.copyParent) {
      _assertInitialization();
    }

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
    if (inheritanceType == DiInheritanceType.copyParent) {
      _assertInitialization();
    }

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
    _disposables.add(disposer);
  }

  void _informIfClosed() {
    if (isClosed) {
      print(
        'You\'re accessing an entity via container "$name" which is closed, '
        'i.e. it\'s entities disposed and deleted. '
        'This might result in an unexpected behaviour.',
      );
    }
  }

  Future<void> _disposeAll() =>
      Future.wait(_disposables.map((value) async => await value()));

  void _assertInitialization() {
    assert(
      _isInitialized,
      'Container "$name" with inheritance type "copyParent" has not been initialized yet. '
      'Thus, "get", "getAsync", "maybeGet", "maybeGetAsync" and "isRegistered" methods '
      'will not work properly and are forbidden from use.',
    );
  }

  DiContainerBase? _getFirstNonCopyAncestor() {
    DiContainerBase? nonCopyAncestor;

    _visitAncestors((ancestor) {
      if (ancestor.inheritanceType != DiInheritanceType.copyParent) {
        nonCopyAncestor = ancestor;
        return false;
      }

      return true;
    });

    return nonCopyAncestor;
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

  /// Releases resources and erases registered entities inside of the container.
  ///
  @override
  Future<void> close() async {
    await _disposeAll();
    _registrationCallbacks.clear();
    _disposables.clear();
    _entitiesMap.clear();
    _isClosed = true;
  }
}
