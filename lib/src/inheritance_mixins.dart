part of 'di_container.dart';

base mixin DiContainerImplCopyParentMixin on DiContainerImpl {
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
    return _getFirstNonCopyAncestor()?._isRegisteredInAncestors<T>() ?? false;
  }

  DiContainerImpl? _getFirstNonCopyAncestor() {
    DiContainerImpl? nonCopyAncestor;

    _visitAncestors((ancestor) {
      if (ancestor is! DiContainerImplCopyParentMixin) {
        nonCopyAncestor = ancestor;
        return false;
      }
      return true;
    });

    return nonCopyAncestor;
  }
}

base mixin DiContainerImplLinkParentMixin on DiContainerImpl {
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
}
