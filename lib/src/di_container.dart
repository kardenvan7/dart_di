import 'dart:async';
import 'dart:collection';

import 'dart_di_config.dart';
import 'di_entity.dart';
import 'di_retriever.dart';
import 'di_registrar.dart';
import 'di_inheritance_type.dart';

part 'di_container_non_inheritance_alternative.dart';
part 'implementation.dart';
part 'inheritance_mixins.dart';

sealed class DiContainerBase implements DiRegistrar, DiRetriever {
  String get name;

  List<String> get hierarchy;

  DiInheritanceType get inheritanceType;

  DiContainerBase? get _parent;

  HashMap<Type, DiEntity> get _registeredMap;

  bool get isInitialized;

  bool get isSealed;

  bool get isClosed;

  T? _lookUp<T>({required Object? param1, required Object? param2});

  Future<T>? _lookUpAsync<T>({
    required Object? param1,
    required Object? param2,
  });

  bool _isRegisteredInAncestors<T>();

  void _seal();

  Future<void> close();
}

/// A class that is used for registering, containing and providing
/// entities via type.
///
abstract final class DiContainer implements DiContainerBase {
  /// A class that is used for registering, containing and providing
  /// entities via type.
  ///
  /// [name] - name of the container. Primarily used in debugging functions for
  /// better identification of each container.
  ///
  /// [inheritanceType] - a type of inheritance which will be applied to the
  /// current container. See [DiInheritanceType] for more information.
  ///
  /// [parent] - a parent container which entities will be available via
  /// this container, if not overshadowed.
  ///
  factory DiContainer(
    String name, {
    DiInheritanceType? inheritanceType,
    DiContainerBase? parent,
  }) = DiContainerImpl;

  /// Initializes the container, after which it is possible to retrieve
  /// registered entities from it.
  ///
  void initialize();
}

abstract final class DiContainerAsync
    implements DiContainerBase, DiRegistrarAsync {
  /// A class that is used for registering, containing and providing
  /// entities via type.
  ///
  /// [name] - name of the container. Primarily used in debugging functions for
  /// better identification of each container.
  ///
  /// [inheritanceType] - a type of inheritance which will be applied to the
  /// current container. See [DiInheritanceType] for more information.
  ///
  /// [parent] - a parent container which entities will be available via
  /// this container, if not overshadowed.
  ///
  factory DiContainerAsync(
    String name, {
    DiInheritanceType? inheritanceType,
    DiContainerBase? parent,
  }) = DiContainerAsyncImpl;

  /// Initializes the container, after which it is possible to retrieve
  /// registered entities from it.
  ///
  Future<void> initialize();
}
