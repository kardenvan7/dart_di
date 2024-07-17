import 'di_inheritance_type.dart';

/// A global configuration class for `dart_di` package functionality.
///
abstract final class DartDiConfig {
  /// A default inheritance type of containers, which is applied when
  /// no implicit [inheritanceType] is provided to container upon it's
  /// creation.
  ///
  static DiInheritanceType defaultInheritanceType =
      DiInheritanceType.linkParent;
}
