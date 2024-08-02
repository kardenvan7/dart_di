import 'dart:async';
import 'dart:collection';

import 'dart_di_config.dart';
import 'di_entity.dart';
import 'di_retriever.dart';
import 'di_registrar.dart';
import 'di_inheritance_type.dart';

part 'implementation.dart';
part 'inheritance_mixins.dart';

sealed class DiContainerBase implements DiRegistrar, DiRetriever {
  /// Returns a list of types, registered in this container.
  ///
  List<Type> get registeredTypes;

  /// A name of the container. Helpful for debugging.
  ///
  String get name;

  /// Returns a list of container names, starting from this one,
  /// followed by it's parents until a parent container
  /// with no parent.
  ///
  List<String> get hierarchy;

  bool get isInitialized;

  /// Returns true, if the container has already been sealed.
  ///
  /// "Sealed" means that no further registrations in the container
  /// are allowed.
  ///
  bool get isSealed;

  /// Returns true, if this container has already been closed.
  ///
  /// Read [close] method description for more information.
  ///
  bool get isClosed;

  DiContainerBase? get _parent;

  HashMap<Type, DiEntity> get _entitiesMap;

  T? _lookUp<T>({required Object? param1, required Object? param2});

  Future<T>? _lookUpAsync<T>({
    required Object? param1,
    required Object? param2,
  });

  bool _isRegisteredInAncestors<T>();

  void _seal();

  /// Closes the container, disposing all disposable entites inside of it
  /// and removing all registrations.
  ///
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
