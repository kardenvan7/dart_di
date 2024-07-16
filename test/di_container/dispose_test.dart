import 'package:dart_di/dart_di.dart';
import 'package:dart_di/src/di_container.dart';
import 'package:test/test.dart';

import '../util_classes.dart';

void main() {
  group(
    'Dispose',
    () {
      DiContainer getUut() => DiContainer('');
      DiContainerAsync getAsyncUut() => DiContainerAsync('');

      test(
        'Singleton is disposed',
        () async {
          final uut = getUut();

          bool isDisposed = false;

          uut.registerSingleton(
            DisposableClass(() => isDisposed = true),
            dispose: (instance) => instance.dispose(),
          );
          uut.initialize();

          expect(isDisposed, isFalse);

          await uut.close();

          expect(isDisposed, isTrue);
        },
      );

      test(
        'Lazy singleton is disposed',
        () async {
          final uut = getUut();

          bool isDisposed = false;

          uut.registerLazySingleton(
            () => DisposableClass(() => isDisposed = true),
            dispose: (instance) => instance.dispose(),
          );
          uut.initialize();

          // Needed for instance creation
          uut.get<DisposableClass>();

          expect(isDisposed, isFalse);

          await uut.close();

          expect(isDisposed, isTrue);
        },
      );

      test(
        'Singleton async is disposed',
        () async {
          final uut = getAsyncUut();

          bool isDisposed = false;

          uut.registerSingletonAsync(
            () async => Future.delayed(
              const Duration(milliseconds: 100),
              () => DisposableClass(() => isDisposed = true),
            ),
            dispose: (instance) => instance.dispose(),
          );

          await uut.initialize();

          expect(isDisposed, isFalse);

          await uut.close();

          expect(isDisposed, isTrue);
        },
      );

      test(
        'Lazy singleton async is disposed',
        () async {
          final uut = getUut();

          bool isDisposed = false;

          uut.registerLazySingletonAsync(
            () async => Future.delayed(
              const Duration(milliseconds: 100),
              () => DisposableClass(() => isDisposed = true),
            ),
            dispose: (instance) => instance.dispose(),
          );
          uut.initialize();

          // Needed for instance creation
          await uut.getAsync<DisposableClass>();

          expect(isDisposed, isFalse);

          await uut.close();

          expect(isDisposed, isTrue);
        },
      );
    },
  );
}
