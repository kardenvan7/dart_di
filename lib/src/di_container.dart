import 'dart:async';
import 'dart:developer';

import 'dart_di_config.dart';
import 'di_entity.dart';
import 'di_retriever.dart';
import 'di_registrar.dart';
import 'di_inheritance_type.dart';

part 'implementation.dart';
part 'inheritance_mixins.dart';

/// A class that is used for registering, containing and providing
/// entities via type.
///
sealed class DiContainer implements DiContainerBase {
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

sealed class DiContainerAsync implements DiContainerBase, DiRegistrarAsync {
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
