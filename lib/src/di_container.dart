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
  factory DiContainer(
    String name, {
    DiInheritanceType? inheritanceType,
  }) =>
      switch (inheritanceType ?? DartDiConfig.defaultInheritanceType) {
        DiInheritanceType.copyParent => DiContainerImplCopyParent(name),
        DiInheritanceType.linkParent => DiContainerImplLinkParent(name),
        DiInheritanceType.ignoreParent => DiContainerImplIgnoreParent(name),
      };

  /// A container's name. Useful for debugging purposes.
  ///
  String get name;

  /// A list of names of all containers starting from this one up to the top.
  ///
  /// Useful for debugging purposes.
  ///
  List<String> get hierarchy;

  /// Sets a [parent] for the container.
  ///
  /// A [parent] is used for dependency look-ups and retrieving entities
  /// that are not registered in the current container.
  ///
  /// Setting the parent before registering any dependencies is advised. Also,
  /// changing the parent after any registrations have been done can lead to
  /// unexpected behaviours and, thus, heavily discouraged.
  ///
  void setParent(DiContainer? parent);

  /// Releases resources and erases registered entities inside of the container.
  ///
  Future<void> close();
}
