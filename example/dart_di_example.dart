import 'dart:developer';

import 'package:dart_di/dart_di.dart' as dart_di;
import 'package:dart_di/src/di_container.dart';

void main(List<String> arguments) async {
  final diContainer = await _setupDi();

  final component1 = diContainer.get<_Clazz1>();
  final component4 = await diContainer.getAsync<_Clazz4>();

  log(
    'Components $component1, $component4 and others have been registered and retrieved successfully',
  );
}

Future<dart_di.DiContainer> _setupDi() async {
  final container = DiContainer('global_scope');

  container
    ..registerFactory<_Clazz1>(() => _Clazz1())
    ..registerSingleton<_Clazz2>(_Clazz2())
    ..registerLazySingleton<_Clazz3>(() => _Clazz3())
    ..registerFactoryAsync<_Clazz4>(
      () => Future.delayed(const Duration(milliseconds: 100), () => _Clazz4()),
    )
    ..registerLazySingletonAsync<_Clazz5>(
      () => Future.delayed(const Duration(milliseconds: 100), () => _Clazz5()),
    );

  await container.registerSingletonAsync<_Clazz6>(
    () => Future.delayed(const Duration(milliseconds: 100), () => _Clazz6()),
  );

  return container;
}

class _Clazz1 {}

class _Clazz2 {}

class _Clazz3 {}

class _Clazz4 {}

class _Clazz5 {}

class _Clazz6 {}
