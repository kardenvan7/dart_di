/// An interface for retrieving registered entities.
///
abstract interface class DiRetriever {
  /// Retrieves an entity, registered with type [T]. Throws an error, if no
  /// entity was registered under that type.
  ///
  T get<T>({Object? param1, Object? param2});

  /// Retrieves an entity, registered with type [T]. Returns null, if no
  /// entity was registered under that type.
  ///
  T? maybeGet<T>({Object? param1, Object? param2});

  /// Asynchronously retrieves an entity, registered with type [T]. Throws an
  /// error, if no entity was registered under that type.
  ///
  Future<T> getAsync<T>({Object? param1, Object? param2});

  /// Asynchronously retrieves an entity, registered with type [T]. Returns
  /// null, if no entity was registered under that type.
  ///
  Future<T>? maybeGetAsync<T>({Object? param1, Object? param2});

  /// Returns [true] if any entity was registered with type [T]. Otherwise,
  /// returns [false].
  ///
  bool isRegistered<T>();
}
