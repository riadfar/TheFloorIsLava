/// Typed failures.
///
/// The domain and data layers never throw raw exceptions at the UI and never
/// build user-facing strings. They return one of these; the presentation layer
/// decides what to say about it.
sealed class Failure {
  const Failure({this.cause});

  /// The underlying error, kept for diagnostics only. It must never be shown
  /// to the user.
  final Object? cause;
}

/// Why a stored scenario could not be read or written.
enum PersistenceFailureKind {
  /// Storage could not be reached at all.
  unavailable,

  /// Something was stored, but it is not readable as a scenario.
  corrupted,

  /// Stored by a version of the app this one cannot interpret.
  unsupportedVersion,
}

class PersistenceFailure extends Failure {
  const PersistenceFailure(this.kind, {super.cause});

  final PersistenceFailureKind kind;

  @override
  String toString() => 'PersistenceFailure($kind, cause: $cause)';
}

/// Imported data that does not describe a usable scenario.
class ImportFailure extends Failure {
  const ImportFailure({super.cause});

  @override
  String toString() => 'ImportFailure(cause: $cause)';
}
