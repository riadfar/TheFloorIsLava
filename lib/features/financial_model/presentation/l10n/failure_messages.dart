import '../../../../core/error/failures.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// Turns a typed failure into something a person can act on.
///
/// Raw exceptions never reach the user; this is the only translation point.
String failureMessage(AppLocalizations l10n, Failure failure) {
  return switch (failure) {
    PersistenceFailure(:final kind) => switch (kind) {
      PersistenceFailureKind.unavailable => l10n.errorStorageUnavailable,
      PersistenceFailureKind.corrupted => l10n.errorStorageCorrupted,
      PersistenceFailureKind.unsupportedVersion => l10n.errorStorageUnsupported,
    },
    ImportFailure() => l10n.errorGeneric,
  };
}
