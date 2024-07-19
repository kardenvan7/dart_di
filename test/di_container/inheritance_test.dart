import 'package:dart_di/dart_di.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group(
    'Inheritance',
    () {
      group(
        'Link parent',
        () {
          DiContainer getUut({String? name, DiContainer? parent}) =>
              DiContainer(
                name ?? 'uut',
                inheritanceType: DiInheritanceType.linkParent,
                parent: parent,
              );

          test(
            'Parent entity is retrieved',
            () {
              final parent = getUut();
              parent.registerSingleton<SimpleClass>(SimpleClass());
              parent.initialize();

              final uut = getUut(parent: parent);
              uut.initialize();

              expect(uut.isRegistered<SimpleClass>(), isTrue);
            },
          );

          test(
            '"hierarchy" returns all container\'s names in a bottom-to-top order',
            () {
              final parentOfParent = getUut(name: 'parentOfParent');
              final parent = getUut(name: 'parent', parent: parentOfParent);
              final uut = getUut(parent: parent);
              uut.initialize();

              expect(uut.hierarchy.length, 3);
              expect(uut.hierarchy.first, uut.name);
              expect(uut.hierarchy[1], parent.name);
              expect(uut.hierarchy[2], parentOfParent.name);
            },
          );

          test(
            'Parent registration is overshadowed by the child',
            () {
              final parent = getUut(name: 'parent');
              final parentSingleton = SimpleClass();
              parent.registerSingleton<SimpleClass>(parentSingleton);
              parent.initialize();

              final uut = getUut(parent: parent);
              final uutSingleton = SimpleClass();
              uut.registerSingleton<SimpleClass>(uutSingleton);
              uut.initialize();

              expect(uut.get<SimpleClass>() == uutSingleton, isTrue);
              expect(uut.get<SimpleClass>() == parentSingleton, isFalse);
            },
          );
        },
      );

      group(
        'Copy parent',
        () {
          DiContainer getUut({String? name, DiContainer? parent}) =>
              DiContainer(
                name ?? 'uut',
                inheritanceType: DiInheritanceType.copyParent,
                parent: parent,
              );

          test(
            'Parent entity is retrieved',
            () {
              final parent = getUut();
              parent.registerSingleton<SimpleClass>(SimpleClass());
              parent.initialize();

              final uut = getUut(parent: parent);
              uut.initialize();

              expect(uut.isRegistered<SimpleClass>(), isTrue);
            },
          );

          test(
            '"hierarchy" returns all container\'s names in a bottom-to-top order',
            () {
              final parentOfParent = getUut(name: 'parentOfParent');
              final parent = getUut(name: 'parent', parent: parentOfParent);
              final uut = getUut(parent: parent);

              expect(uut.hierarchy.length, 3);
              expect(uut.hierarchy.first, uut.name);
              expect(uut.hierarchy[1], parent.name);
              expect(uut.hierarchy[2], parentOfParent.name);
            },
          );

          test(
            'Parent registration is overshadowed by the child',
            () {
              final parent = getUut(name: 'parent');
              final parentSingleton = SimpleClass();
              parent.registerSingleton<SimpleClass>(parentSingleton);
              parent.initialize();

              final uut = getUut(parent: parent);
              final uutSingleton = SimpleClass();
              uut.registerSingleton<SimpleClass>(uutSingleton);
              uut.initialize();

              expect(uut.get<SimpleClass>() == uutSingleton, isTrue);
              expect(uut.get<SimpleClass>() == parentSingleton, isFalse);
            },
          );

          test(
            'Upon closing, only directly registered entities are erased',
            () async {
              final parent = getUut(name: 'parent');
              final parentSingleton = InstantiableClass(() {});
              parent
                ..registerFactory<SimpleClass>(() => SimpleClass())
                ..registerSingleton<InstantiableClass>(parentSingleton)
                ..initialize();

              final uut = getUut(parent: parent);
              final uutSingleton = InstantiableClass(() {});
              uut
                ..registerSingleton<InstantiableClass>(uutSingleton)
                ..registerFactory<DisposableClass>(() => DisposableClass(() {}))
                ..initialize();

              expect(uut.maybeGet<SimpleClass>(), isA<SimpleClass>());
              expect(uut.maybeGet<InstantiableClass>(), equals(uutSingleton));
              expect(uut.maybeGet<DisposableClass>(), isA<DisposableClass>());

              await uut.close();

              expect(parent.maybeGet<SimpleClass>(), isA<SimpleClass>());
              expect(
                parent.maybeGet<InstantiableClass>(),
                equals(parentSingleton),
              );
              expect(parent.maybeGet<DisposableClass>(), isNull);
            },
          );
        },
      );
    },
  );
}
