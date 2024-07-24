import 'package:dart_di/dart_di.dart';
import 'package:get_it/get_it.dart';

void main() async {
  final globalContainer = await _setupContainer();

  final getIt = await _setupGetIt();
  const repeatCount = 2;

  print('GETIT DI: ');

  for (int i = 0; i < repeatCount; i++) {
    measure(getIt.get<_Clazz1>, '_Clazz1');
    measure(getIt.get<_Clazz2>, '_Clazz2');
    measure(getIt.get<_Clazz3>, '_Clazz3');
    measure(getIt.get<_Clazz7>, '_Clazz7');
    measure(getIt.get<_Clazz8>, '_Clazz8');
    measure(getIt.get<_Clazz9>, '_Clazz9');
    measure(getIt.get<_Clazz10>, '_Clazz10');
    measure(getIt.get<_Clazz11>, '_Clazz11');
    measure(getIt.get<_Clazz12>, '_Clazz12');
    measure(getIt.get<_Clazz13>, '_Clazz13');
    measure(getIt.get<_Clazz14>, '_Clazz14');
    measure(getIt.get<_Clazz15>, '_Clazz15');
    measure(getIt.get<_Clazz16>, '_Clazz16');
    measure(getIt.get<_Clazz17>, '_Clazz17');
  }

  print('FLUTTER DI: ');
  for (int i = 0; i < repeatCount; i++) {
    measure(globalContainer.get<_Clazz1>, '_Clazz1');
    measure(globalContainer.get<_Clazz2>, '_Clazz2');
    measure(globalContainer.get<_Clazz3>, '_Clazz3');
    measure(globalContainer.get<_Clazz7>, '_Clazz7');
    measure(globalContainer.get<_Clazz8>, '_Clazz8');
    measure(globalContainer.get<_Clazz9>, '_Clazz9');
    measure(globalContainer.get<_Clazz10>, '_Clazz10');
    measure(globalContainer.get<_Clazz11>, '_Clazz11');
    measure(globalContainer.get<_Clazz12>, '_Clazz12');
    measure(globalContainer.get<_Clazz13>, '_Clazz13');
    measure(globalContainer.get<_Clazz14>, '_Clazz14');
    measure(globalContainer.get<_Clazz15>, '_Clazz15');
    measure(globalContainer.get<_Clazz16>, '_Clazz16');
    measure(globalContainer.get<_Clazz17>, '_Clazz17');
  }
}

Future<DiContainerAsync> _setupContainer() async {
  final container = DiContainerAsync(
    'global_scope',
    inheritanceType: DiInheritanceType.copyParent,
  );

  container
    ..registerFactory<_Clazz1>(() => _Clazz1())
    ..registerSingleton<_Clazz2>(() => _Clazz2())
    ..registerLazySingleton<_Clazz3>(() => _Clazz3())
    ..registerFactoryAsync<_Clazz4>(
      () => Future.delayed(const Duration(milliseconds: 100), () => _Clazz4()),
    )
    ..registerLazySingletonAsync<_Clazz5>(
      () => Future.delayed(const Duration(milliseconds: 100), () => _Clazz5()),
    )
    ..registerSingletonAsync<_Clazz6>(
      () => Future.delayed(const Duration(milliseconds: 100), () => _Clazz6()),
    )
    ..registerSingleton<_Clazz7>(() => _Clazz7())
    ..registerSingleton<_Clazz8>(() => _Clazz8())
    ..registerSingleton<_Clazz9>(() => _Clazz9())
    ..registerSingleton<_Clazz10>(() => _Clazz10())
    ..registerSingleton<_Clazz11>(() => _Clazz11())
    ..registerSingleton<_Clazz12>(() => _Clazz12())
    ..registerSingleton<_Clazz13>(() => _Clazz13())
    ..registerSingleton<_Clazz14>(() => _Clazz14())
    ..registerSingleton<_Clazz15>(() => _Clazz15())
    ..registerSingleton<_Clazz16>(() => _Clazz16())
    ..registerSingleton<_Clazz17>(() => _Clazz17());

  await container.initialize();

  return container;
}

Future<GetIt> _setupGetIt() async {
  final getIt = GetIt.asNewInstance();

  getIt
    ..registerFactory<_Clazz1>(() => _Clazz1())
    ..registerSingleton<_Clazz2>(_Clazz2())
    ..registerLazySingleton<_Clazz3>(() => _Clazz3())
    ..registerFactoryAsync<_Clazz4>(
      () => Future.delayed(const Duration(milliseconds: 100), () => _Clazz4()),
    )
    ..registerLazySingletonAsync<_Clazz5>(
      () => Future.delayed(const Duration(milliseconds: 100), () => _Clazz5()),
    )
    ..registerSingletonAsync<_Clazz6>(
      () => Future.delayed(const Duration(milliseconds: 100), () => _Clazz6()),
    )
    ..registerSingleton<_Clazz7>(_Clazz7())
    ..registerSingleton<_Clazz8>(_Clazz8())
    ..registerSingleton<_Clazz9>(_Clazz9())
    ..registerSingleton<_Clazz10>(_Clazz10())
    ..registerSingleton<_Clazz11>(_Clazz11())
    ..registerSingleton<_Clazz12>(_Clazz12())
    ..registerSingleton<_Clazz13>(_Clazz13())
    ..registerSingleton<_Clazz14>(_Clazz14())
    ..registerSingleton<_Clazz15>(_Clazz15())
    ..registerSingleton<_Clazz16>(_Clazz16())
    ..registerSingleton<_Clazz17>(_Clazz17());

  await getIt.allReady();

  return getIt;
}

class _Clazz1 {}

class _Clazz2 {}

class _Clazz3 {}

class _Clazz4 {}

class _Clazz5 {}

class _Clazz6 {}

class _Clazz7 {}

class _Clazz8 {}

class _Clazz9 {}

class _Clazz10 {}

class _Clazz11 {}

class _Clazz12 {}

class _Clazz13 {}

class _Clazz14 {}

class _Clazz15 {}

class _Clazz16 {}

class _Clazz17 {}

T measure<T>(T Function() callback, String text, {skip = false}) {
  final sw = Stopwatch()..start();
  final callbackResult = callback();
  final elapsed = sw.elapsedMicroseconds;
  if (!skip) print('$text: $elapsed');
  sw.stop();
  return callbackResult;
}
