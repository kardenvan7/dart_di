part of 'di_container.dart';

base mixin DiContainerBaseCopyParentMixin on DiContainerBase {
  @override
  Map<Type, DiEntity> _registeredMap = {};

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
  bool _isRegisteredInAncestors<T>() {
    _assertInitialization();
    return _getFirstNonCopyAncestor()?._isRegisteredInAncestors<T>() ?? false;
  }

  @override
  T? maybeGet<T>({Object? param1, Object? param2}) {
    _assertInitialization();
    return super.maybeGet<T>(param1: param1, param2: param2);
  }

  @override
  Future<T>? maybeGetAsync<T>({Object? param1, Object? param2}) {
    _assertInitialization();
    return super.maybeGetAsync<T>(param1: param1, param2: param2);
  }

  @override
  void _onInitializationStart() {
    if (_parent != null) {
      _parent!._seal();
      _registeredMap = {..._parent!._registeredMap};
    }
  }

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
      if (ancestor is! DiContainerBaseCopyParentMixin) {
        nonCopyAncestor = ancestor;
        return false;
      }

      return true;
    });

    return nonCopyAncestor;
  }
}

base mixin DiContainerBaseLinkParentMixin on DiContainerBase {
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

  void _onInitializationStart() {
    if (_parent != null && !_parent!.isInitialized) {
      log(
        'Container "name" is being initialized, but it\'s parent ${_parent!.name} it not initilized. '
        'It is advised to initialize parent containers prior to their children to avoid potential bugs.',
      );
    }
  }

  @override
  bool _isRegisteredInAncestors<T>() => _parent?.isRegistered<T>() ?? false;
}
