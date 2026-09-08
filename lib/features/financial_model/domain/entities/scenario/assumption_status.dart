/// How much confidence an input value carries.
///
/// The source study mixes hard quotes (equipment prices) with rough guesses
/// (rent, customs, occupancy). Presenting them identically would overstate the
/// reliability of the model, so every named input carries a status.
enum AssumptionStatus {
  /// A rough estimate that still has to be checked against reality.
  estimated,

  /// Checked against an external source, but not contractually fixed.
  verified,

  /// Fixed by a quote, contract or invoice.
  confirmed,

  /// Entered by the user of the application, provenance unknown.
  userDefined,

  /// Brought in from another system or document.
  imported,
}

/// Stable identifiers for every named, editable input of the model.
///
/// Keys let the presentation layer attach validation messages, help text and an
/// [AssumptionStatus] to a specific input without the domain knowing anything
/// about widgets. Additional (user-created) expense and cost items are not
/// listed here; they carry their own status on the item itself.
enum AssumptionKey {
  roundDuration,
  turnaroundTime,
  ticketPrice,
  averagePlayersPerRound,
  maximumPlayersPerRound,
  operatingHoursPerDay,
  operatingDaysPerWeek,
  operatingDaysPerMonth,
  occupancyMonth1,
  occupancyMonth2,
  occupancyMonth3,
  stableOccupancy,
  initialEmployeeCount,
  expandedEmployeeCount,
  expansionMonth,
  monthlySalaryPerEmployee,
  monthlyIncentivePerEmployee,
  rent,
  mallSharedServices,
  electricity,
  maintenance,
  continuousMarketing,
  mallDeposit,
  contractDurationMonths,
  selectedEquipmentPackage,
  shippingRate,
  customsRate,
  fitOutFurniture,
  fitOutPainting,
  fitOutSignage,
  fitOutHvac,
  fitOutInstallationLabour,
  licensing,
  openingMarketing,
  contingencyRate,
  maximumSetupDays,
  projectionMonths,
  conservativeOccupancy,
  optimisticOccupancy,
}

/// The confidence status attached to each named input.
///
/// Anything not present in [statuses] falls back to [defaultStatus], which keeps
/// the map small and makes forward compatibility trivial when new keys appear.
class AssumptionAnnotations {
  const AssumptionAnnotations({
    this.statuses = const {},
    this.defaultStatus = AssumptionStatus.estimated,
  });

  final Map<AssumptionKey, AssumptionStatus> statuses;
  final AssumptionStatus defaultStatus;

  AssumptionStatus statusOf(AssumptionKey key) =>
      statuses[key] ?? defaultStatus;

  AssumptionAnnotations withStatus(
    AssumptionKey key,
    AssumptionStatus status,
  ) => AssumptionAnnotations(
    statuses: {...statuses, key: status},
    defaultStatus: defaultStatus,
  );

  @override
  bool operator ==(Object other) {
    if (other is! AssumptionAnnotations) return false;
    if (other.defaultStatus != defaultStatus) return false;
    if (other.statuses.length != statuses.length) return false;
    for (final entry in statuses.entries) {
      if (other.statuses[entry.key] != entry.value) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    defaultStatus,
    Object.hashAllUnordered(
      statuses.entries.map((e) => Object.hash(e.key, e.value)),
    ),
  );
}
