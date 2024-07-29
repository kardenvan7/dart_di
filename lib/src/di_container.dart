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

  String get name;

  List<String> get hierarchy;

  bool get isSealed;

  bool get isClosed;

  void seal();

  Future<void> close();
}
