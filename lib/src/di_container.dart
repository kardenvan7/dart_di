import 'dart:async';
import 'dart:collection';

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
abstract final class DiContainer implements DiRegistrarAsync, DiRetriever {
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
    DiContainer? parent,
  }) = DiContainerImpl;

  /// Returns a list of registered types in this container.
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

  /// Returns true, if the container has already been sealed.
  ///
  /// Read [seal] method description for more information.
  ///
  bool get isSealed;

  /// Returns true, if this container has already been closed.
  ///
  /// Read [close] method description for more information.
  ///
  bool get isClosed;

  /// Seals the container, disallowing any future registrations in it.
  ///
  void seal();

  /// Closes the container, disposing all disposable entites inside of it
  /// and removing all registrations.
  ///
  Future<void> close();
}
