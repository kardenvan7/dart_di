import 'dart:async';

/// An interface for registering entities inside of a container.
///
abstract interface class DiRegistrar {
  /// Registers a factory of entity of type [T].
  ///
  /// Each call of [DiGetter.get] will return an instance by invoking
  /// [callback].
  ///
  void registerFactory<T>(T Function() callback);

  /// Registers a factory of entity of type [T] with parameters of types [P1]
  /// and [P2].
  ///
  /// Each call of [DiGetter.get] will return an instance by invoking
  /// [callback].
  ///
  void registerFactoryParam<T, P1, P2>(T Function(P1, P2) callback);

  /// Registers a singleton of entity of type [T].
  ///
  /// Each call of [DiGetter.get] will return the same [instance].
  ///
  /// [dispose] - function that is triggered when the container is being
  /// destroyed. Usually used for disposing of the resources created by the
  /// registered instance.
  ///
  void registerSingleton<T>(
    T instance, {
    FutureOr Function(T)? dispose,
  });

  /// Registers a lazy singleton of entity of type [T].
  ///
  /// The first call of [DiGetter.get] will retrieve and save an instance by
  /// running [callback]. Each consequent call will just return the saved
  /// instance.
  ///
  /// [dispose] - a callback that is triggered when the container is being
  /// destroyed. Usually used for disposing of the resources created by the
  /// registered instance. The function provides the instance, if created. If
  /// the singleton was not created before closing the container, the function
  /// won't be triggered at all.
  ///
  void registerLazySingleton<T>(
    T Function() callback, {
    FutureOr Function(T)? dispose,
  });

  /// Registers a lazy singleton of entity of type [T] with parameters
  /// of types [P1] and [P2].
  ///
  /// The first call of [DiGetter.get] will retrieve and save an instance by
  /// running [callback]. Each consequent call will just return the saved
  /// instance.
  ///
  /// [dispose] - a callback that is triggered when the container is being
  /// destroyed. Usually used for disposing of the resources created by the
  /// registered instance. The function provides the instance, if created. If
  /// the singleton was not created before closing the container, the function
  /// won't be triggered at all.
  ///
  void registerLazySingletonParam<T, P1, P2>(
    T Function(P1, P2) callback, {
    FutureOr Function(T)? dispose,
  });

  /// Registers an asynchronous factory of entity of type [T].
  ///
  /// Each call of [DiGetter.getAsync] will asynchronously return an instance by
  /// invoking [callback].
  ///
  /// Calling a [DiGetter.get] on the type registered with this method will
  /// throw an error.
  ///
  void registerFactoryAsync<T>(Future<T> Function() callback);

  /// Registers an asynchronous factory of entity of type [T] with parameters
  /// of types [P1] and [P2].
  ///
  /// Each call of [DiGetter.getAsync] will asynchronously return an instance by
  /// invoking [callback].
  ///
  /// Calling a [DiGetter.get] on the type registered with this method will
  /// throw an error.
  ///
  void registerFactoryAsyncParam<T, P1, P2>(
    Future<T> Function(P1, P2) callback,
  );

  /// Registers a lazy asynchronous singleton of entity of type [T].
  ///
  /// The first call of [DiGetter.getAsync] will asynchronously retrieve and
  /// save an instance by running [callback]. Each consequent call will just
  /// return the saved instance.
  ///
  /// [allowConsequentGetCalls] - controls if [DiGetter.get] can be used to
  /// retrieve the instance after at least one [DiGetter.getAsync] has
  /// successfully returned it.
  ///
  /// [dispose] - a callback that is triggered when the container is being
  /// destroyed. Usually used for disposing of the resources created by the
  /// registered instance. The function provides the instance, if created. If
  /// the singleton was not created before closing the container, the function
  /// won't be triggered at all.
  ///
  void registerLazySingletonAsync<T>(
    Future<T> Function() callback, {
    bool allowConsequentGetCalls = true,
    FutureOr Function(T)? dispose,
  });

  /// Registers a lazy asynchronous singleton of entity of type [T] with
  /// parameters of types [P1] and [P2].
  ///
  /// The first call of [DiGetter.getAsync] will asynchronously retrieve and
  /// save an instance by running [callback]. Each consequent call will just
  /// return the saved instance.
  ///
  /// [allowConsequentGetCalls] - controls if [DiGetter.get] can be used to
  /// retrieve the instance after at least one [DiGetter.getAsync] has
  /// successfully returned it.
  ///
  /// [dispose] - a callback that is triggered when the container is being
  /// destroyed. Usually used for disposing of the resources created by the
  /// registered instance. The function provides the instance, if created. If
  /// the singleton was not created before closing the container, the function
  /// won't be triggered at all.
  ///
  void registerLazySingletonAsyncParam<T, P1, P2>(
    Future<T> Function(P1, P2) callback, {
    bool allowConsequentGetCalls = true,
    FutureOr Function(T)? dispose,
  });
}

/// An interface for registering dependencies inside of a asynchronous
/// container.
///
abstract interface class DiRegistrarAsync implements DiRegistrar {
  /// Asynchronously registers a singleton of entity of type [T].
  ///
  /// Each call of [DiGetter.get] will return the same [instance].
  ///
  /// [dispose] - function that is triggered when the container is being
  /// destroyed. Usually used for disposing of the resources created by the
  /// registered instance.
  ///
  Future<void> registerSingletonAsync<T>(
    Future<T> Function() callback, {
    FutureOr Function(T)? dispose,
  });
}
