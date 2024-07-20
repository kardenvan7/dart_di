// ignore_for_file: unused_local_variable
import 'package:dart_di/dart_di.dart';
import 'package:get_it/get_it.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  const List<int> containerCounts = [
    1,
    2,
    5,
    10,
    20,
    30,
    40,
    50,
    60,
    100,
    250,
    500,
    1000,
  ];

  DiContainerNonInh prepareNonInhContainer({
    required DiInheritanceType inheritanceType,
    int containersAmount = 1,
  }) {
    DiContainerNonInh container =
        DiContainerNonInh('0', inheritanceType: inheritanceType)
          ..registerFactory<_ValueClass1>(() => _ValueClass1('1'))
          ..registerSingleton<_ValueClass2>(() => _ValueClass2('2'))
          ..initialize();

    for (int i = 1; i < containersAmount; i++) {
      container = DiContainerNonInh(
        '$i',
        inheritanceType: inheritanceType,
        parent: container,
      )..initialize();
    }

    return container;
  }

  DiContainerBase prepareContainer({
    required DiInheritanceType inheritanceType,
    int containersAmount = 1,
  }) {
    DiContainerBase container = DiContainer('0')
      ..registerFactory<_ValueClass1>(() => _ValueClass1('1'))
      ..registerSingleton<_ValueClass2>(() => _ValueClass2('2'))
      ..initialize();

    for (int i = 1; i < containersAmount; i++) {
      container = DiContainer(
        '$i',
        parent: container,
        inheritanceType: inheritanceType,
      )..initialize();
    }

    return container;
  }

  GetIt prepareGetIt() {
    final getIt = GetIt.asNewInstance();

    getIt
      ..registerFactory<_ValueClass1>(() => _ValueClass1('1'))
      ..registerSingleton<_ValueClass2>(_ValueClass2('2'));

    return getIt;
  }

  group(
    'Comparison',
    () {
      void runTests(
        String name,
        DiInheritanceType inheritanceType,
      ) {
        group(
          name,
          () {
            for (final containerCount in containerCounts) {
              test(
                'Containers count: $containerCount',
                () {
                  void runComparisonTest(
                    DiContainerBase container,
                    DiContainerNonInh nonInhContainer,
                    GetIt getIt,
                  ) {
                    const repeatCount = 1;

                    for (int i = 0; i < repeatCount; i++) {
                      measure(() => container.get<_ValueClass2>(), 'FluDi');
                    }

                    for (int i = 0; i < repeatCount; i++) {
                      measure(
                        () => nonInhContainer.get<_ValueClass2>(),
                        'FluDi Inh',
                      );
                    }

                    for (int i = 0; i < repeatCount; i++) {
                      measure(() => getIt.get<_ValueClass2>(), 'GetIt');
                    }
                  }

                  final container = prepareContainer(
                    inheritanceType: inheritanceType,
                    containersAmount: containerCount,
                  );
                  final nonInhContainer = prepareNonInhContainer(
                    inheritanceType: inheritanceType,
                    containersAmount: containerCount,
                  );
                  final getIt = prepareGetIt();

                  runComparisonTest(container, nonInhContainer, getIt);
                },
              );
            }
          },
        );
      }

      runTests('Link Parent', DiInheritanceType.linkParent);
      runTests('Copy Parent', DiInheritanceType.copyParent);
    },
  );
}

class _ValueClass1 {
  const _ValueClass1(this.value);

  final String value;
}

class _ValueClass2 {
  const _ValueClass2(this.value);

  final String value;
}
