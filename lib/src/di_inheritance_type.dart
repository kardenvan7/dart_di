/// The types of container inheritance behaviour.
///
enum DiInheritanceType {
  /// Upon setting a parent, parent registrations will be copied to it.
  ///
  /// This type of inheritance uses more memory, but requires less time to
  /// look up for entities in parent containers. (Though, the memory consumption
  /// difference in most cases is really small).
  ///
  copyParent,

  /// Upon settings a parent, parent will be linked to it as a field.
  ///
  /// This type of inheritance is more memory efficient, but requires more
  /// time to look up for entities in parent containers. (Though, the time
  /// difference only becomes substantial when a container has to look for an
  /// entity in more than 50-60 parents. That is, if all parents use this
  /// inheritance type since each [copyParent]-type container reduces the
  /// look up time by the amount depending on how many [copyParent] containers
  /// in a row are above it).
  ///
  linkParent,

  /// Completely ignores parent container (and thus, all containers above
  /// it).
  ///
  /// Useful for cases where it is desired to completely isolate the container from
  /// the rest of the registered entities above.
  ///
  /// Use with care, since any of the containers which has a container as their
  /// parent or above it, will also not be  able to see any entities from above.
  ///
  ignoreParent;
}
