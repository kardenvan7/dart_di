import 'package:dart_di/src/di_container.dart';

abstract final class DartDiConfig {
  static DiInheritanceType defaultInheritanceType =
      DiInheritanceType.linkParent;
}
