import 'package:dart_di/dart_di.dart';
import 'package:test/test.dart';

import '../util_classes.dart';

void main() {
  group(
    'Inheritance',
    () {
      group(
        'Link parent',
        () {
          DiContainer getUut([String? name]) => DiContainer(
                name ?? 'uut',
                inheritanceType: DiInheritanceType.linkParent,
              );

          test(
            'Parent entity is retrieved after linking',
            () {
              final parent = getUut();
              parent.registerSingleton<SimpleClass>(SimpleClass());

              final uut = getUut();

              expect(uut.isRegistered<SimpleClass>(), isFalse);

              uut.setParent(parent);

              expect(uut.isRegistered<SimpleClass>(), isTrue);
            },
          );

          test(
            '"hierarchy" returns all container\'s names in a bottom-to-top order',
            () {
              final parentOfParent = getUut('parentOfParent');
              final parent = getUut('parent');
              final uut = getUut();

              expect(uut.hierarchy.length, 1);
              expect(uut.hierarchy.first, uut.name);

              parent.setParent(parentOfParent);
              uut.setParent(parent);

              expect(uut.hierarchy.length, 3);
              expect(uut.hierarchy.first, uut.name);
              expect(uut.hierarchy[1], parent.name);
              expect(uut.hierarchy[2], parentOfParent.name);
            },
          );

          test(
            'Parent registration is overshadowed by the child',
            () {
              final parent = getUut('parent');
              final parentSingleton = SimpleClass();
              parent.registerSingleton<SimpleClass>(parentSingleton);

              final uut = getUut();
              final uutSingleton = SimpleClass();
              parent.registerSingleton<SimpleClass>(uutSingleton);

              uut.setParent(parent);

              expect(uut.get<SimpleClass>() == uutSingleton, isTrue);
              expect(uut.get<SimpleClass>() == parentSingleton, isFalse);
            },
          );
        },
      );

      group(
        'Copy parent',
        () {
          DiContainer getUut([String? name]) => DiContainer(
                name ?? 'uut',
                inheritanceType: DiInheritanceType.copyParent,
              );

          test(
            'Parent entity is retrieved after linking',
            () {
              final parent = getUut();
              parent.registerSingleton<SimpleClass>(SimpleClass());

              final uut = getUut();

              expect(uut.isRegistered<SimpleClass>(), isFalse);

              uut.setParent(parent);

              expect(uut.isRegistered<SimpleClass>(), isTrue);
            },
          );

          test(
            '"hierarchy" returns all container\'s names in a bottom-to-top order',
            () {
              final parentOfParent = getUut('parentOfParent');
              final parent = getUut('parent');
              final uut = getUut();

              expect(uut.hierarchy.length, 1);
              expect(uut.hierarchy.first, uut.name);

              parent.setParent(parentOfParent);
              uut.setParent(parent);

              expect(uut.hierarchy.length, 3);
              expect(uut.hierarchy.first, uut.name);
              expect(uut.hierarchy[1], parent.name);
              expect(uut.hierarchy[2], parentOfParent.name);
            },
          );

          test(
            'Parent registration is overshadowed by the child',
            () {
              final parent = getUut('parent');
              final parentSingleton = SimpleClass();
              parent.registerSingleton<SimpleClass>(parentSingleton);

              final uut = getUut();
              final uutSingleton = SimpleClass();
              parent.registerSingleton<SimpleClass>(uutSingleton);

              uut.setParent(parent);

              expect(uut.get<SimpleClass>() == uutSingleton, isTrue);
              expect(uut.get<SimpleClass>() == parentSingleton, isFalse);
            },
          );
        },
      );

      group(
        'Ignore parent',
        () {
          DiContainer getUut([String? name]) => DiContainer(
                name ?? 'uut',
                inheritanceType: DiInheritanceType.ignoreParent,
              );

          test(
            'Parent entity is not retrieved after linking',
            () {
              final parent = DiContainer(
                'parent',
                inheritanceType: DiInheritanceType.copyParent,
              );
              parent.registerSingleton<SimpleClass>(SimpleClass());

              final uut = getUut();

              expect(uut.isRegistered<SimpleClass>(), isFalse);

              uut.setParent(parent);

              expect(uut.isRegistered<SimpleClass>(), isFalse);
            },
          );

          test(
            '"hierarchy" returns only the current container\'s name',
            () {
              final parentOfParent = DiContainer(
                'parentOfParent',
              );
              final parent = DiContainer(
                'parent',
                inheritanceType: DiInheritanceType.copyParent,
              );
              final uut = getUut();

              expect(uut.hierarchy.length, 1);
              expect(uut.hierarchy.first, uut.name);

              parent.setParent(parentOfParent);
              uut.setParent(parent);

              expect(uut.hierarchy.length, 1);
              expect(uut.hierarchy.first, uut.name);
            },
          );

          test(
            'Any container below "ignoreParent" container also can not see any '
            'entities from containers above closest "ignoreParent" container',
            () {
              final parentOfParent = DiContainer('parentOfParent');
              final parent = DiContainer(
                'parent',
                inheritanceType: DiInheritanceType.copyParent,
              );
              final uut = getUut();
              final child = DiContainer(
                'child',
                inheritanceType: DiInheritanceType.copyParent,
              );
              final childOfChild = DiContainer(
                'childOfChild',
                inheritanceType: DiInheritanceType.copyParent,
              );

              expect(uut.hierarchy.length, 1);
              expect(uut.hierarchy.first, uut.name);

              parent.setParent(parentOfParent);
              uut.setParent(parent);
              child.setParent(uut);
              childOfChild.setParent(child);

              expect(uut.hierarchy.length, 1);
              expect(uut.hierarchy.first, uut.name);
              expect(child.hierarchy.length, 2);
              expect(childOfChild.hierarchy.length, 3);
            },
          );
        },
      );
    },
  );
}
