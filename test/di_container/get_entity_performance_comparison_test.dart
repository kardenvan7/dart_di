import 'package:dart_di/dart_di.dart';
import 'package:get_it/get_it.dart';
import 'package:test/test.dart';

void main() {
  const List<int> containerCounts = [
    1,
    1,
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
    1000
  ];

  DiContainer prepareContainer({
    required DiInheritanceType inheritanceType,
    int containersAmount = 1,
  }) {
    DiContainer container = DiContainer('0')
      ..registerFactory<_ValueClass1>(() => _ValueClass1('1'))
      ..registerSingleton<_ValueClass2>(_ValueClass2('2'))
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

    return getIt
      ..registerFactory<_ValueClass1>(() => _ValueClass1('1'))
      ..registerSingleton<_ValueClass2>(_ValueClass2('2'));
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
                  final List<String> prints = [];

                  void log(Object? message) {
                    prints.add(message.toString());
                  }

                  void runComparisonTest(DiContainer container, GetIt getIt) {
                    const repeatCount = 2;

                    for (int i = 0; i < repeatCount; i++) {
                      final sw = Stopwatch()..start();
                      final value = container.get<_ValueClass1>();
                      log('FluDi: ${sw.elapsedMicroseconds}');
                      sw.stop();
                    }

                    for (int i = 0; i < repeatCount; i++) {
                      final sw1 = Stopwatch()..start();
                      final value1 = getIt.get<_ValueClass1>();
                      log('GetIt: ${sw1.elapsedMicroseconds}');
                      sw1.stop();
                    }
                  }

                  final container = prepareContainer(
                    inheritanceType: inheritanceType,
                    containersAmount: containerCount,
                  );
                  final getIt = prepareGetIt();

                  runComparisonTest(container, getIt);

                  for (final printVal in prints) {
                    print(printVal);
                  }
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
