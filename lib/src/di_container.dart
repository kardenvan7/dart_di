import 'dart:async';

import 'dart_di_config.dart';
import 'di_entity.dart';
import 'di_retriever.dart';
import 'di_registrar.dart';
import 'di_inheritance_type.dart';

part 'implementation.dart';
part 'inheritance_mixins.dart';

/// A class that is used for registering, containing and providing
/// entities via [type].
///
sealed class DiContainer implements DiRegistrar, DiRetriever {
  /// A class that is used for registering, containing and providing
  /// entities via [type].
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
    DiContainer? parent,
  }) = DiContainerImpl;

  /// A container's name. Useful for debugging purposes.
  ///
  String get name;

  /// A list of names of all containers starting from this one up to the top.
  ///
  /// Useful for debugging purposes.
  ///
  List<String> get hierarchy;

  /// Releases resources and erases registered entities inside of the container.
  ///
  Future<void> close();
}
