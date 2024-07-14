import 'package:dart_di/dart_di.dart';
import 'package:test/test.dart';

import '../util_classes.dart';

void main() {
  group(
    'Dispose',
    () {
      DiContainer getUut() => DiContainer('');

      test(
        'Singleton is disposed',
        () async {
          final uut = getUut();

          bool isDisposed = false;

          uut.registerSingleton(
            DisposableClass(() => isDisposed = true),
            dispose: (instance) => instance.dispose(),
          );

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
          final uut = getUut();

          bool isDisposed = false;

          await uut.registerSingletonAsync(
            () async => Future.delayed(
              const Duration(milliseconds: 100),
              () => DisposableClass(() => isDisposed = true),
            ),
            dispose: (instance) => instance.dispose(),
          );

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
