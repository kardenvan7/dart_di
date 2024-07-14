part of 'di_container.dart';

mixin DiContainerImplCopyParentMixin on DiContainerImpl {
  @override
  late final Map<Type, DiEntity> _registeredMap = {
    ...(_parent?._registeredMap ?? {})
  };
  final Map<Type, DiEntity> _directlyRegisteredMap = {};

  @override
  T? _lookUp<T>({
    required Object? param1,
    required Object? param2,
  }) =>
      _parent?._lookUp<T>(param1: param1, param2: param2);

  @override
  Future<T>? _lookUpAsync<T>({
    required Object? param1,
    required Object? param2,
  }) =>
      _parent?._lookUpAsync<T>(param1: param1, param2: param2);

  @override
  void _registerEntity<T>(DiEntity<T> entity) {
    super._registerEntity(entity);
    _directlyRegisteredMap[T] = entity;
  }

  @override
  bool _isRegisteredInAncestors<T>() =>
      _getFirstNonCopyAncestor()?._isRegisteredInAncestors<T>() ?? false;

  DiContainerImpl? _getFirstNonCopyAncestor() {
    DiContainerImpl? nonCopyAncestor;

    visitAncestors((ancestor) {
      if (ancestor is! DiContainerImplCopyParentMixin) {
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
        '[${_directlyRegisteredMap.keys.join(', ')}]'
        ')';
  }

  @override
  Future<void> close() {
    _directlyRegisteredMap.clear();
    return super.close();
  }
}

mixin DiContainerImplLinkParentMixin on DiContainerImpl {
  @override
  final Map<Type, DiEntity> _registeredMap = {};

  @override
  T? _lookUp<T>({required Object? param1, required Object? param2}) =>
      _parent?.maybeGet<T>(param1: param1, param2: param2);

  @override
  Future<T>? _lookUpAsync<T>({
    required Object? param1,
    required Object? param2,
  }) =>
      _parent?.maybeGetAsync<T>(param1: param1, param2: param2);

  @override
  bool _isRegisteredInAncestors<T>() => _parent?.isRegistered<T>() ?? false;

  @override
  String toString() {
    return 'DiContainer('
        '$name, '
        '[${_registeredMap.keys.join(', ')}]'
        ')';
  }
}
