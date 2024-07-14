/// The types of container inheritance behaviour.
///
enum DiInheritanceType {
  /// Parent registrations are copied to the child container.
  ///
  /// This type of inheritance uses more memory, but requires less time to
  /// look up for entities in parent containers. (Though, the memory consumption
  /// difference in most cases is really small).
  ///
  copyParent,

  /// Parent is attached to the child via link.
  ///
  /// This type of inheritance is more memory efficient, but requires more
  /// time to look up for entities in parent containers. (Though, the time
  /// difference only becomes substantial when a container has to look for an
  /// entity in more than 50-60 parents. That is if all parents use this
  /// inheritance type, since each [copyParent]-type container reduces the
  /// look up time by the amount depending on how many [copyParent] containers
  /// in a row are above it).
  ///
  linkParent;
}
