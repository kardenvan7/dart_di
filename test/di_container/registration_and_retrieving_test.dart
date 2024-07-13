import 'package:dart_di/src/di_container.dart';
import 'package:test/test.dart';

import '../util_classes.dart';

void main() {
  group(
    'Registration and retrieval',
    () {
      DiContainer getUut() => DiContainer('');

      test(
        'Factory registration returns new instance',
        () {
          final uut = getUut();

          uut.registerFactory(() => SimpleClass());

          final instance1 = uut.get<SimpleClass>();
          final instance2 = uut.get<SimpleClass>();

          expect(instance1 == instance2, isFalse);
        },
      );

      test(
        'Singleton registration returns same instance',
        () {
          final uut = getUut();

          uut.registerSingleton(SimpleClass());

          final instance1 = uut.get<SimpleClass>();
          final instance2 = uut.get<SimpleClass>();

          expect(instance1 == instance2, isTrue);
        },
      );

      test(
        'Lazy singleton registration returns same instance',
        () {
          final uut = getUut();

          uut.registerLazySingleton(() => SimpleClass());

          final instance1 = uut.get<SimpleClass>();
          final instance2 = uut.get<SimpleClass>();

          expect(instance1 == instance2, isTrue);
        },
      );

      test(
        'Lazy singleton creates instance one time on-demand',
        () {
          final uut = getUut();

          int instancesCreated = 0;

          uut.registerLazySingleton(
            () => InstantiableClass(() => instancesCreated++),
          );

          expect(instancesCreated, 0);

          uut.get<InstantiableClass>();

          expect(instancesCreated, 1);

          uut.get<InstantiableClass>();

          expect(instancesCreated, 1);
        },
      );

      test(
        'Singleton async registration returns same instance',
        () async {
          final uut = getUut();

          await uut.registerSingletonAsync(
            () async => Future.delayed(
              const Duration(milliseconds: 100),
              () => SimpleClass(),
            ),
          );

          final instance1 = await uut.get<SimpleClass>();
          final instance2 = await uut.get<SimpleClass>();

          expect(instance1 == instance2, isTrue);
        },
      );

      test(
        'Factory async registration returns new instance',
        () async {
          final uut = getUut();

          uut.registerFactoryAsync(
            () async => Future.delayed(
              const Duration(milliseconds: 100),
              () => SimpleClass(),
            ),
          );

          final instance1 = await uut.getAsync<SimpleClass>();
          final instance2 = await uut.getAsync<SimpleClass>();

          expect(instance1 == instance2, isFalse);
        },
      );

      test(
        'Lazy singleton async registration returns same instance',
        () async {
          final uut = getUut();

          uut.registerLazySingletonAsync(
            () async => Future.delayed(
              const Duration(milliseconds: 100),
              () => SimpleClass(),
            ),
          );

          final instance1 = await uut.getAsync<SimpleClass>();
          final instance2 = await uut.getAsync<SimpleClass>();

          expect(instance1 == instance2, isTrue);
        },
      );

      test(
        'Lazy singleton async can be retrieved with get only after first getAsync returns',
        () async {
          final uut = getUut();

          uut.registerLazySingletonAsync(
            () async => Future.delayed(
              const Duration(milliseconds: 100),
              () => SimpleClass(),
            ),
          );

          expect(uut.get<SimpleClass>, throwsException);

          await uut.getAsync<SimpleClass>();

          expect(uut.get<SimpleClass>(), isInstanceOf<SimpleClass>());
        },
      );

      test(
        '"get" throws an exception when type is not registered',
        () {
          final uut = getUut();

          expect(uut.get<SimpleClass>, throwsException);
        },
      );

      test(
        '"get" throws an exception when trying to retrieve an asynchronous factory registration',
        () async {
          final uut = getUut();
          uut.registerFactoryAsync(() async => SimpleClass());

          expect(uut.get<SimpleClass>, throwsException);
        },
      );

      test(
        '"get" throws an exception when trying to retrieve an asynchronous lazy singleton registration',
        () async {
          final uut = getUut();
          uut.registerLazySingletonAsync(() async => SimpleClass());

          expect(uut.get<SimpleClass>, throwsException);
        },
      );

      test(
        '"getAsync" returns factory',
        () async {
          final uut = getUut();

          uut.registerFactory(() => SimpleClass());

          final instance1 = await uut.getAsync<SimpleClass>();

          expect(instance1, isA<SimpleClass>());
        },
      );

      test(
        '"getAsync" returns singleton',
        () async {
          final uut = getUut();

          uut.registerSingleton(SimpleClass());

          final instance1 = await uut.getAsync<SimpleClass>();

          expect(instance1, isA<SimpleClass>());
        },
      );

      test(
        '"getAsync" returns lazy singleton',
        () async {
          final uut = getUut();

          uut.registerLazySingleton(() => SimpleClass());

          final instance1 = await uut.getAsync<SimpleClass>();

          expect(instance1, isA<SimpleClass>());
        },
      );

      test(
        '"getAsync" throws an exception when type is not registered',
        () {
          final uut = getUut();

          expect(uut.getAsync<SimpleClass>, throwsException);
        },
      );

      test(
        '"maybeGet" returns null when type is not registered',
        () {
          final uut = getUut();
          final result = uut.maybeGet<SimpleClass>();

          expect(result, isNull);
        },
      );

      test(
        '"maybeGetAsync" returns null when type is not registered',
        () async {
          final uut = getUut();
          final result = await uut.maybeGetAsync<SimpleClass>();

          expect(result, isNull);
        },
      );
    },
  );
}
