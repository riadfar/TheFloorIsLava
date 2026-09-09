import 'package:equatable/equatable.dart';

import '../../value_objects/money.dart';
import '../../value_objects/percentage.dart';
import 'cost_item.dart';
import 'equipment_lifecycle_assumptions.dart';

/// One purchasable equipment option.
class EquipmentPackage extends Equatable {
  const EquipmentPackage({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
  });

  final String id;
  final String name;
  final String description;
  final Money cost;

  EquipmentPackage copyWith({String? name, String? description, Money? cost}) {
    return EquipmentPackage(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      cost: cost ?? this.cost,
    );
  }

  @override
  List<Object?> get props => [id, name, description, cost];
}

/// Equipment choice plus the landed-cost rates applied to it.
class EquipmentModel extends Equatable {
  const EquipmentModel({
    required this.packages,
    required this.selectedPackageId,
    required this.shippingRate,
    required this.customsRate,
  });

  /// Available options. The study has two; the list is open-ended so more can
  /// be added without a schema change.
  final List<EquipmentPackage> packages;

  final String selectedPackageId;

  /// Sea freight as a share of the equipment value.
  final Percentage shippingRate;

  /// Customs and clearance as a share of the equipment value.
  final Percentage customsRate;

  /// The chosen package, or the first one if the selection dangles.
  EquipmentPackage get selectedPackage => packages.firstWhere(
    (package) => package.id == selectedPackageId,
    orElse: () => packages.first,
  );

  EquipmentModel copyWith({
    List<EquipmentPackage>? packages,
    String? selectedPackageId,
    Percentage? shippingRate,
    Percentage? customsRate,
  }) {
    return EquipmentModel(
      packages: packages ?? this.packages,
      selectedPackageId: selectedPackageId ?? this.selectedPackageId,
      shippingRate: shippingRate ?? this.shippingRate,
      customsRate: customsRate ?? this.customsRate,
    );
  }

  /// Replaces a package definition, keeping list order and the current
  /// selection intact.
  EquipmentModel withPackage(EquipmentPackage package) {
    return copyWith(
      packages: [
        for (final existing in packages)
          if (existing.id == package.id) package else existing,
      ],
    );
  }

  @override
  List<Object?> get props => [
    packages,
    selectedPackageId,
    shippingRate,
    customsRate,
  ];
}

/// One-off works needed to turn an empty unit into the attraction.
class FitOutModel extends Equatable {
  const FitOutModel({
    required this.receptionFurniture,
    required this.paintingAndGraphics,
    required this.signage,
    required this.hvac,
    required this.installationLabour,
    this.additionalItems = const [],
  });

  final Money receptionFurniture;
  final Money paintingAndGraphics;
  final Money signage;
  final Money hvac;
  final Money installationLabour;
  final List<CostItem> additionalItems;

  FitOutModel copyWith({
    Money? receptionFurniture,
    Money? paintingAndGraphics,
    Money? signage,
    Money? hvac,
    Money? installationLabour,
    List<CostItem>? additionalItems,
  }) {
    return FitOutModel(
      receptionFurniture: receptionFurniture ?? this.receptionFurniture,
      paintingAndGraphics: paintingAndGraphics ?? this.paintingAndGraphics,
      signage: signage ?? this.signage,
      hvac: hvac ?? this.hvac,
      installationLabour: installationLabour ?? this.installationLabour,
      additionalItems: additionalItems ?? this.additionalItems,
    );
  }

  @override
  List<Object?> get props => [
    receptionFurniture,
    paintingAndGraphics,
    signage,
    hvac,
    installationLabour,
    additionalItems,
  ];
}

/// Terms of the unit itself.
class PropertyModel extends Equatable {
  const PropertyModel({
    required this.mallDeposit,
    required this.contractDurationMonths,
  });

  /// Deposit or key money payable up front.
  final Money mallDeposit;

  /// Length of the lease. Descriptive in this model - it is planning context,
  /// not an input to any formula in the study.
  final int contractDurationMonths;

  PropertyModel copyWith({Money? mallDeposit, int? contractDurationMonths}) {
    return PropertyModel(
      mallDeposit: mallDeposit ?? this.mallDeposit,
      contractDurationMonths:
          contractDurationMonths ?? this.contractDurationMonths,
    );
  }

  @override
  List<Object?> get props => [mallDeposit, contractDurationMonths];
}

/// Costs incurred before the doors open, other than fit-out and property.
class PreOpeningModel extends Equatable {
  const PreOpeningModel({
    required this.registrationAndLicensing,
    required this.openingMarketingCampaign,
    required this.contingencyRate,
    required this.maximumSetupDays,
    this.additionalItems = const [],
  });

  final Money registrationAndLicensing;
  final Money openingMarketingCampaign;

  /// Buffer applied to the whole start-up subtotal.
  final Percentage contingencyRate;

  /// Planning figure only: the longest expected setup once goods land. It does
  /// not enter any formula, matching the source study.
  final int maximumSetupDays;

  final List<CostItem> additionalItems;

  PreOpeningModel copyWith({
    Money? registrationAndLicensing,
    Money? openingMarketingCampaign,
    Percentage? contingencyRate,
    int? maximumSetupDays,
    List<CostItem>? additionalItems,
  }) {
    return PreOpeningModel(
      registrationAndLicensing:
          registrationAndLicensing ?? this.registrationAndLicensing,
      openingMarketingCampaign:
          openingMarketingCampaign ?? this.openingMarketingCampaign,
      contingencyRate: contingencyRate ?? this.contingencyRate,
      maximumSetupDays: maximumSetupDays ?? this.maximumSetupDays,
      additionalItems: additionalItems ?? this.additionalItems,
    );
  }

  @override
  List<Object?> get props => [
    registrationAndLicensing,
    openingMarketingCampaign,
    contingencyRate,
    maximumSetupDays,
    additionalItems,
  ];
}

/// Everything that has to be paid before month 1 can trade.
class StartupCostModel extends Equatable {
  const StartupCostModel({
    required this.equipment,
    required this.fitOut,
    required this.property,
    required this.preOpening,
    this.equipmentLifecycle = const EquipmentLifecycleAssumptions(),
  });

  final EquipmentModel equipment;
  final FitOutModel fitOut;
  final PropertyModel property;
  final PreOpeningModel preOpening;
  final EquipmentLifecycleAssumptions equipmentLifecycle;

  StartupCostModel copyWith({
    EquipmentModel? equipment,
    FitOutModel? fitOut,
    PropertyModel? property,
    PreOpeningModel? preOpening,
    EquipmentLifecycleAssumptions? equipmentLifecycle,
  }) {
    return StartupCostModel(
      equipment: equipment ?? this.equipment,
      fitOut: fitOut ?? this.fitOut,
      property: property ?? this.property,
      preOpening: preOpening ?? this.preOpening,
      equipmentLifecycle: equipmentLifecycle ?? this.equipmentLifecycle,
    );
  }

  @override
  List<Object?> get props => [
    equipment,
    fitOut,
    property,
    preOpening,
    equipmentLifecycle,
  ];
}
