// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'الأرض حمم';

  @override
  String get appSubtitle => 'نموذج الجدوى المالية';

  @override
  String get navDashboard => 'لوحة المعلومات';

  @override
  String get navAssumptions => 'الافتراضات';

  @override
  String get navStaffing => 'فريق العمل';

  @override
  String get navSeasonality => 'الموسمية';

  @override
  String get navProjection => 'التوقعات';

  @override
  String get navStartup => 'تكاليف التأسيس';

  @override
  String get navSensitivity => 'تحليل الحساسية';

  @override
  String get navScenarios => 'السيناريوهات';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get dashboardTitle => 'لوحة المعلومات';

  @override
  String get assumptionsTitle => 'الافتراضات';

  @override
  String get staffingTitle => 'جدول فريق العمل';

  @override
  String get seasonalityTitle => 'الموسمية';

  @override
  String get projectionTitle => 'التوقعات الشهرية';

  @override
  String get startupTitle => 'تكاليف التأسيس';

  @override
  String get sensitivityTitle => 'تحليل الحساسية';

  @override
  String get scenariosTitle => 'السيناريوهات';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get loading => 'جارٍ التحميل';

  @override
  String get close => 'إغلاق';

  @override
  String get cancel => 'إلغاء';

  @override
  String get reset => 'إعادة ضبط';

  @override
  String get save => 'حفظ';

  @override
  String get done => 'تم';

  @override
  String get notAvailable => 'غير متاح';

  @override
  String get howIsThisCalculated => 'كيف تم احتساب ذلك؟';

  @override
  String get calculationTitle => 'طريقة الاحتساب';

  @override
  String get formulaLabel => 'المعادلة';

  @override
  String get inputsLabel => 'القيم المستخدمة';

  @override
  String get resultLabel => 'النتيجة';

  @override
  String normalMonth(int month) {
    return 'شهر اعتيادي (الشهر $month)';
  }

  @override
  String monthLabel(int month) {
    return 'الشهر $month';
  }

  @override
  String get monthZeroLabel => 'الشهر 0 - الاستثمار';

  @override
  String monthShort(int month) {
    return 'ش$month';
  }

  @override
  String yearLabel(int year) {
    return 'السنة $year';
  }

  @override
  String yearPartial(int year) {
    return 'السنة $year (جزئية)';
  }

  @override
  String get metricInitialInvestment => 'الاستثمار الأولي';

  @override
  String get metricMonthlyRevenue => 'الإيرادات الشهرية';

  @override
  String get metricMonthlyExpenses => 'المصروفات الشهرية';

  @override
  String get metricMonthlyProfit => 'الربح الشهري';

  @override
  String get metricProfitMargin => 'هامش الربح';

  @override
  String get metricPayback => 'فترة الاسترداد';

  @override
  String get metricYearOneProfit => 'ربح السنة الأولى';

  @override
  String get metricYearTwoProfit => 'ربح السنة الثانية';

  @override
  String get metricYearOneRoi => 'عائد الاستثمار للسنة الأولى';

  @override
  String get metricOccupancy => 'الإشغال المستقر';

  @override
  String get metricRoundsPerDay => 'الجولات يوميًا';

  @override
  String get metricNpv => 'صافي القيمة الحالية (NPV)';

  @override
  String get metricIrr => 'معدل العائد الداخلي (IRR)';

  @override
  String get metricDiscountedPayback => 'فترة الاسترداد المخصومة';

  @override
  String get metricBreakEvenOccupancy => 'إشغال نقطة التعادل';

  @override
  String get metricBreakEvenRevenue => 'إيرادات نقطة التعادل';

  @override
  String get metricRequiredFunding => 'التمويل المطلوب';

  @override
  String get metricFundingGap => 'فجوة التمويل';

  @override
  String get metricMinimumCash => 'الحد الأدنى للرصيد النقدي';

  @override
  String get metricWorkingCapital => 'رأس المال العامل';

  @override
  String get irrUnavailable =>
      'معدل العائد الداخلي غير متاح لأن التدفقات النقدية لا تنتج نتيجة فريدة.';

  @override
  String get metricUnavailable => 'غير متاح وفق الافتراضات الحالية.';

  @override
  String get roiStudyDefinition =>
      'ربح السنة الأولى مقسومًا على الاستثمار الأولي، وفق تعريف الدراسة الأصلية.';

  @override
  String paybackDuringMonth(int month) {
    return 'خلال الشهر $month';
  }

  @override
  String get paybackNotRecovered => 'لم يُسترد';

  @override
  String paybackNotRecoveredWithin(int months) {
    return 'لم يُسترد خلال $months شهرًا';
  }

  @override
  String paybackPrecise(String months) {
    return '$months شهرًا (بالاستيفاء)';
  }

  @override
  String paybackLastNegative(int month) {
    return 'آخر شهر بعجز: الشهر $month';
  }

  @override
  String paybackFirstPositive(int month) {
    return 'أول شهر بفائض: الشهر $month';
  }

  @override
  String get chartRevenueTitle => 'الإيرادات الشهرية';

  @override
  String get chartRevenueSubtitle => 'إيرادات كل شهر تشغيل';

  @override
  String get chartCashFlowTitle => 'التدفق النقدي التراكمي';

  @override
  String get chartCashFlowSubtitle => 'استرداد الاستثمار بمرور الوقت';

  @override
  String get chartBreakEvenLine => 'نقطة التعادل';

  @override
  String get chartNoData => 'لا توجد بيانات لعرضها بعد';

  @override
  String get sectionSessionPricing => 'الجلسة والتسعير';

  @override
  String get sectionOccupancy => 'الإشغال';

  @override
  String get sectionStaffing => 'التوظيف';

  @override
  String get sectionOperatingExpenses => 'مصروفات التشغيل الشهرية';

  @override
  String get sectionProperty => 'العقار';

  @override
  String get sectionEquipment => 'المعدات';

  @override
  String get sectionFitOut => 'التجهيز الداخلي';

  @override
  String get sectionPreOpening => 'ما قبل الافتتاح';

  @override
  String get sectionProjection => 'التوقعات';

  @override
  String get sectionSensitivityInputs => 'سيناريوهات الحساسية';

  @override
  String get fieldRoundDuration => 'مدة الجولة';

  @override
  String get fieldTurnaroundTime => 'وقت التجهيز بين الجولات';

  @override
  String get fieldTicketPrice => 'سعر التذكرة لكل لاعب';

  @override
  String get fieldAveragePlayers => 'متوسط اللاعبين في الجولة';

  @override
  String get fieldMaximumPlayers => 'الحد الأقصى للاعبين في الجولة';

  @override
  String get fieldOperatingHours => 'ساعات التشغيل يوميًا';

  @override
  String get fieldOperatingDaysPerWeek => 'أيام التشغيل أسبوعيًا';

  @override
  String get fieldOperatingDaysPerMonth => 'أيام التشغيل شهريًا';

  @override
  String get fieldOccupancyMonth1 => 'إشغال الشهر الأول';

  @override
  String get fieldOccupancyMonth2 => 'إشغال الشهر الثاني';

  @override
  String get fieldOccupancyMonth3 => 'إشغال الشهر الثالث';

  @override
  String get fieldStableOccupancy =>
      'الإشغال المستقر (من الشهر الرابع فصاعدًا)';

  @override
  String get fieldInitialEmployees => 'عدد الموظفين عند البدء';

  @override
  String get fieldExpandedEmployees => 'عدد الموظفين بعد التوسع';

  @override
  String get fieldExpansionMonth => 'يبدأ التوسع في الشهر';

  @override
  String get fieldSalary => 'الراتب الشهري لكل موظف';

  @override
  String get fieldIncentive => 'الحافز الشهري لكل موظف';

  @override
  String get fieldRent => 'الإيجار';

  @override
  String get fieldMallServices => 'الخدمات المشتركة للمركز التجاري';

  @override
  String get fieldElectricity => 'الكهرباء';

  @override
  String get fieldMaintenance => 'الصيانة والمواد الاستهلاكية';

  @override
  String get fieldMarketing => 'التسويق المستمر';

  @override
  String get fieldMallDeposit => 'تأمين المركز التجاري / خلوّ الرجل';

  @override
  String get fieldContractDuration => 'مدة العقد';

  @override
  String get fieldEquipmentPackage => 'حزمة المعدات';

  @override
  String get fieldShippingRate => 'نسبة الشحن البحري';

  @override
  String get fieldCustomsRate => 'نسبة الجمارك والتخليص';

  @override
  String get fieldFitOutFurniture => 'أثاث الاستقبال والصندوق';

  @override
  String get fieldFitOutPainting => 'الدهان ورسومات الجدران';

  @override
  String get fieldFitOutSignage => 'اللافتات';

  @override
  String get fieldFitOutHvac => 'التدفئة والتهوية وتكييف الهواء';

  @override
  String get fieldFitOutLabour => 'عمالة التركيب';

  @override
  String get fieldLicensing => 'التسجيل والترخيص';

  @override
  String get fieldOpeningMarketing => 'الحملة التسويقية للافتتاح';

  @override
  String get fieldContingency => 'احتياطي الطوارئ';

  @override
  String get fieldSetupDays => 'الحد الأقصى لأيام التجهيز بعد الوصول';

  @override
  String get fieldProjectionMonths => 'مدة التوقعات';

  @override
  String get fieldConservativeOccupancy => 'الإشغال المتحفظ';

  @override
  String get fieldOptimisticOccupancy => 'الإشغال المتفائل';

  @override
  String get helpTurnaround =>
      'وقت إعادة التجهيز بين الجولات. يستهلك وقت التشغيل رغم أنه غير مباع.';

  @override
  String get helpAveragePlayers =>
      'هذه قيمة متوسطة، لذا يُتوقع أن تكون كسرية. ولا يجوز أن تتجاوز سعة الغرفة.';

  @override
  String get helpOperatingDaysPerWeek =>
      'مسجلة لأغراض التخطيط. ويُستخدم الإجمالي الشهري أدناه في احتساب الإيرادات.';

  @override
  String get helpOperatingDaysPerMonth =>
      'أيام التشغيل في شهر اعتيادي. تستخدم الدراسة 30.4 يومًا.';

  @override
  String get helpOccupancy =>
      'نسبة الجولات المتاحة التي تُباع فعليًا. وهذا هو الافتراض الأكثر تأثيرًا في النموذج.';

  @override
  String get helpRent =>
      'يُحتسب أيضًا مرة واحدة كإيجار الشهر الأول ضمن تكلفة العقار عند التأسيس، تمامًا كما في الدراسة الأصلية.';

  @override
  String get helpMaximumPlayers =>
      'السعة الفعلية للغرفة. تحدّ من المتوسط، لكنها لا تؤثر بذاتها في الإيرادات.';

  @override
  String get helpContractDuration =>
      'مسجلة لأغراض التخطيط، ولا تدخل في أي معادلة في هذا النموذج.';

  @override
  String get helpSetupDays =>
      'مسجلة لأغراض التخطيط، ولا تدخل في أي معادلة في هذا النموذج.';

  @override
  String get helpShipping => 'تُطبق على قيمة حزمة المعدات المحددة.';

  @override
  String get helpContingency =>
      'هامش احتياطي يُطبق على الإجمالي الفرعي لتكاليف التأسيس.';

  @override
  String get helpSensitivity =>
      'يعيد كل سيناريو تسعير شهر اعتيادي عند مستوى إشغال مختلف باستخدام قاعدة تكاليف مرحلة الاستقرار.';

  @override
  String get calculatedShipping => 'تكلفة الشحن المحتسبة';

  @override
  String get calculatedCustoms => 'تكلفة الجمارك المحتسبة';

  @override
  String get calculatedValue => 'محتسبة';

  @override
  String get editableValue => 'قابلة للتعديل';

  @override
  String get unitMinutes => 'دقيقة';

  @override
  String get unitHours => 'ساعة';

  @override
  String get unitDays => 'أيام';

  @override
  String get unitMonths => 'أشهر';

  @override
  String get unitPercent => '٪';

  @override
  String get unitPlayers => 'لاعبين';

  @override
  String get unitPeople => 'أشخاص';

  @override
  String get perMonth => '/ شهر';

  @override
  String get perDay => '/ يوم';

  @override
  String get perRound => '/ جولة';

  @override
  String get statusEstimated => 'تقديري';

  @override
  String get statusVerified => 'تم التحقق منه';

  @override
  String get statusConfirmed => 'مؤكد';

  @override
  String get statusUserDefined => 'محدد من المستخدم';

  @override
  String get statusImported => 'مستورد';

  @override
  String get statusEstimatedHint => 'تقديري - تحقّق منه قبل الاعتماد عليه';

  @override
  String get statusSectionTitle => 'درجة الموثوقية';

  @override
  String assumptionStatusChanged(String status) {
    return 'تم تغيير الحالة إلى $status';
  }

  @override
  String validationMustBeGreaterThan(String limit) {
    return 'يجب أن تكون القيمة أكبر من $limit';
  }

  @override
  String validationMustBeAtLeast(String limit) {
    return 'يجب ألا تقل القيمة عن $limit';
  }

  @override
  String validationMustNotExceed(String limit) {
    return 'يجب ألا تتجاوز القيمة $limit';
  }

  @override
  String validationPlayersExceedCapacity(String limit) {
    return 'لا يجوز تجاوز سعة الغرفة البالغة $limit';
  }

  @override
  String get validationRoundTimeNotPositive =>
      'يجب أن تستغرق الجولة ووقت التجهيز مدة زمنية موجبة';

  @override
  String get validationContingencyAboveHundred =>
      'احتياطي طوارئ يتجاوز 100٪ يضاعف تكلفة المشروع. تحقّق من هذه القيمة.';

  @override
  String validationOptimisticBelowBase(String limit) {
    return 'هذا السيناريو المتفائل أقل من الإشغال المستقر البالغ $limit٪. تتضمن الدراسة الأصلية التباين نفسه.';
  }

  @override
  String validationConservativeAboveBase(String limit) {
    return 'السيناريو المتحفظ أعلى من الإشغال المستقر البالغ $limit٪.';
  }

  @override
  String get validationExpandedBelowInitial =>
      'عدد الموظفين بعد التوسع أقل من عددهم عند البدء.';

  @override
  String get validationNotANumber => 'أدخل رقمًا';

  @override
  String validationSummaryErrors(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مدخل يحتاج إلى مراجعة',
      many: '$count مدخلًا يحتاج إلى مراجعة',
      few: '$count مدخلات تحتاج إلى مراجعة',
      two: 'مدخلان يحتاجان إلى مراجعة',
      one: 'مدخل واحد يحتاج إلى مراجعة',
    );
    return '$_temp0';
  }

  @override
  String validationSummaryWarnings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count افتراض يستحق التحقق',
      many: '$count افتراضًا يستحق التحقق',
      few: '$count افتراضات تستحق التحقق',
      two: 'افتراضان يستحقان التحقق',
      one: 'افتراض واحد يستحق التحقق',
    );
    return '$_temp0';
  }

  @override
  String get validationBlocksSaving =>
      'لا تُحفظ التغييرات ما دام أحد المدخلات غير صالح.';

  @override
  String get termTotalRoundTime => 'إجمالي وقت الجولة';

  @override
  String get termOperatingMinutes => 'دقائق التشغيل يوميًا';

  @override
  String get termMaximumRounds => 'الحد الأقصى للجولات';

  @override
  String get termActualRounds => 'الجولات الفعلية';

  @override
  String get termOccupancy => 'الإشغال';

  @override
  String get termDailyRevenue => 'الإيرادات اليومية';

  @override
  String get termMonthlyRevenue => 'الإيرادات الشهرية';

  @override
  String get termCumulativeRevenue => 'الإيرادات التراكمية';

  @override
  String get termEmployees => 'الموظفون';

  @override
  String get termCostPerEmployee => 'التكلفة لكل موظف';

  @override
  String get termPayroll => 'تكلفة الرواتب';

  @override
  String get termOtherExpenses => 'المصروفات الأخرى';

  @override
  String get termTotalExpenses => 'إجمالي المصروفات';

  @override
  String get termOperatingProfit => 'الربح التشغيلي';

  @override
  String get termProfitMargin => 'هامش الربح';

  @override
  String get termNetCashFlow => 'صافي التدفق النقدي';

  @override
  String get termCumulativeCashFlow => 'التدفق النقدي التراكمي';

  @override
  String get termPreviousCumulativeCashFlow => 'التدفق النقدي التراكمي السابق';

  @override
  String get termEquipment => 'المعدات';

  @override
  String get termShipping => 'الشحن البحري';

  @override
  String get termCustoms => 'الجمارك والتخليص';

  @override
  String get termDeliveredEquipment => 'المعدات بعد التسليم';

  @override
  String get termFitOut => 'التجهيز الداخلي';

  @override
  String get termProperty => 'العقار';

  @override
  String get termPreOpening => 'ما قبل الافتتاح';

  @override
  String get termSubtotal => 'الإجمالي الفرعي';

  @override
  String get termContingency => 'احتياطي الطوارئ';

  @override
  String get termInitialInvestment => 'الاستثمار الأولي';

  @override
  String get termYearOneProfit => 'ربح السنة الأولى';

  @override
  String get termLastNegativeMonth => 'آخر شهر بعجز';

  @override
  String get termShortfall => 'المبلغ المتبقي لاسترداده';

  @override
  String get termMonth => 'الشهر';

  @override
  String get termFirstMonthRent => 'إيجار الشهر الأول';

  @override
  String get termMallDeposit => 'تأمين المركز التجاري';

  @override
  String get termLicensing => 'التسجيل والترخيص';

  @override
  String get termOpeningMarketing => 'حملة الافتتاح';

  @override
  String get formulaMaximumRounds =>
      'الجزء الصحيح (دقائق التشغيل يوميًا / إجمالي وقت الجولة)';

  @override
  String get formulaActualRounds => 'الحد الأقصى للجولات × الإشغال';

  @override
  String get formulaDailyRevenue =>
      'الجولات الفعلية × متوسط اللاعبين × سعر التذكرة';

  @override
  String get formulaMonthlyRevenue => 'الإيرادات اليومية × أيام التشغيل شهريًا';

  @override
  String get formulaPayroll => 'الموظفون × (الراتب + الحافز)';

  @override
  String get formulaTotalExpenses =>
      'الرواتب + الإيجار + خدمات المركز التجاري + الكهرباء + الصيانة + التسويق';

  @override
  String get formulaOperatingProfit =>
      'الإيرادات الشهرية - إجمالي مصروفات التشغيل';

  @override
  String get formulaProfitMargin => 'الربح التشغيلي / الإيرادات الشهرية';

  @override
  String get formulaDeliveredEquipment => 'المعدات + الشحن + الجمارك';

  @override
  String get formulaContingency =>
      'الإجمالي الفرعي لتكاليف التأسيس × نسبة احتياطي الطوارئ';

  @override
  String get formulaInitialInvestment =>
      'المعدات بعد التسليم + التجهيز الداخلي + العقار + ما قبل الافتتاح + احتياطي الطوارئ';

  @override
  String get formulaCumulativeCashFlow =>
      'التدفق النقدي التراكمي السابق + صافي التدفق النقدي';

  @override
  String get formulaYearOneProfit => 'مجموع الربح التشغيلي من الشهر 1 إلى 12';

  @override
  String get formulaYearOneRoi => 'ربح السنة الأولى / الاستثمار الأولي';

  @override
  String get formulaPayback =>
      'آخر شهر بعجز + (المبلغ المتبقي لاسترداده / صافي التدفق النقدي لذلك الشهر)';

  @override
  String get projectionTableTitle => 'التوقعات الشهرية';

  @override
  String projectionShowsMonths(int count) {
    return 'الشهر 0 بالإضافة إلى $count من أشهر التشغيل';
  }

  @override
  String get projectionInvestmentRow => 'دفع الاستثمار الأولي';

  @override
  String get projectionExpandHint => 'اضغط على شهر لعرض تفاصيله الكاملة';

  @override
  String get columnMonth => 'الشهر';

  @override
  String get startupGroupEquipment => 'المعدات بعد التسليم';

  @override
  String get startupGroupFitOut => 'التجهيز الداخلي';

  @override
  String get startupGroupProperty => 'العقار';

  @override
  String get startupGroupPreOpening => 'ما قبل الافتتاح';

  @override
  String get startupTotal => 'إجمالي الاستثمار الأولي';

  @override
  String get startupExpandHint => 'اضغط على مجموعة لعرض مكوناتها';

  @override
  String startupContingencyAt(String rate) {
    return 'احتياطي الطوارئ بنسبة $rate';
  }

  @override
  String get scenarioConservative => 'متحفظ';

  @override
  String get scenarioBase => 'أساسي';

  @override
  String get scenarioOptimistic => 'متفائل';

  @override
  String get scenarioCustom => 'مخصص';

  @override
  String get scenarioBaseTracksStable => 'يتبع الإشغال المستقر للسيناريو';

  @override
  String get sensitivityApproxPayback => 'فترة الاسترداد التقريبية';

  @override
  String get sensitivityNotRecoverable => 'لا يمكن الاسترداد في هذا السيناريو';

  @override
  String sensitivityMonths(String months) {
    return '$months شهرًا';
  }

  @override
  String sensitivityCostBaseNote(String expenses) {
    return 'يُسعّر كل سيناريو وفق قاعدة تكاليف مرحلة الاستقرار البالغة $expenses شهريًا.';
  }

  @override
  String get scenariosSubtitle =>
      'أنشئ النماذج المالية الكاملة وبدّل بينها وقارنها.';

  @override
  String get scenariosCreateBase => 'جديد من الأساسي';

  @override
  String get scenariosCreateWorst => 'حالة أسوأ جديدة';

  @override
  String get scenariosSaved => 'السيناريوهات المحفوظة';

  @override
  String get scenariosCompare => 'مقارنة السيناريوهات';

  @override
  String get scenariosCompareHint => 'حدد من سيناريوهين إلى أربعة أعلاه.';

  @override
  String get scenariosCompareSelected => 'مقارنة المحدد';

  @override
  String get scenariosComparisonTitle => 'مقارنة السيناريوهات';

  @override
  String scenariosUpdated(String date) {
    return 'آخر تحديث $date';
  }

  @override
  String get scenariosDuplicate => 'تكرار';

  @override
  String get scenariosDelete => 'حذف';

  @override
  String get scenariosDeleteTitle => 'حذف السيناريو؟';

  @override
  String scenariosDeleteBody(String name) {
    return 'حذف «$name»؟ لا يمكن التراجع عن ذلك.';
  }

  @override
  String get scenariosResetBuiltinBody =>
      'السيناريو الأساسي قابل للاستعادة ولا يمكن حذفه. هل تريد إعادة ضبطه إلى قيم الدراسة الأصلية؟';

  @override
  String get scenariosMetric => 'المؤشر';

  @override
  String get settingsScenario => 'السيناريو';

  @override
  String get settingsScenarioName => 'الاسم';

  @override
  String get settingsCurrency => 'العملة';

  @override
  String get settingsDecimalPrecision => 'المنازل العشرية';

  @override
  String get settingsAppearance => 'المظهر';

  @override
  String get settingsTheme => 'السمة';

  @override
  String get settingsThemeSystem => 'اتباع إعداد النظام';

  @override
  String get settingsThemeLight => 'فاتحة';

  @override
  String get settingsThemeDark => 'داكنة';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsLanguageSystem => 'اتباع إعداد النظام';

  @override
  String get settingsLanguageEnglish => 'الإنجليزية';

  @override
  String get settingsLanguageArabic => 'العربية';

  @override
  String get settingsData => 'البيانات';

  @override
  String get settingsAutosaveNote => 'تُحفظ التغييرات تلقائيًا على هذا الجهاز.';

  @override
  String get settingsExportScenario => 'نسخ السيناريو (JSON)';

  @override
  String get settingsScenarioExported => 'تم نسخ JSON السيناريو إلى الحافظة';

  @override
  String get settingsExportProjection => 'نسخ التوقعات (CSV متوافق مع Excel)';

  @override
  String get settingsProjectionExported => 'تم نسخ CSV التوقعات إلى الحافظة';

  @override
  String get settingsImportScenario => 'استيراد سيناريو (JSON)';

  @override
  String get settingsImportJsonHint =>
      'ألصق JSON لسيناريو مُصدّر أدناه، ثم اختر إنشاء سيناريو جديد أو استبدال السيناريو النشط.';

  @override
  String get settingsScenarioJson => 'JSON السيناريو';

  @override
  String get settingsImportCreateNew => 'إنشاء سيناريو جديد';

  @override
  String get settingsImportReplace => 'استبدال السيناريو النشط';

  @override
  String get settingsImportAction => 'استيراد';

  @override
  String get settingsScenarioImported => 'تم استيراد السيناريو بنجاح';

  @override
  String get settingsResetScenario => 'إعادة الضبط إلى خط أساس الدراسة';

  @override
  String get settingsResetDescription =>
      'يتجاهل جميع التغييرات ويستعيد القيم الأصلية.';

  @override
  String get settingsResetConfirmTitle => 'هل تريد إعادة ضبط السيناريو؟';

  @override
  String get settingsResetConfirmBody =>
      'سيتم تجاهل جميع التغييرات التي أجريتها واستعادة قيم الدراسة الأصلية. لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get settingsResetDone => 'تمت إعادة السيناريو إلى خط أساس الدراسة';

  @override
  String get settingsAbout => 'حول التطبيق';

  @override
  String get settingsCalculationModel => 'نموذج الاحتساب';

  @override
  String get settingsAboutBody =>
      'نسخة تفاعلية من دراسة جدوى «الأرض حمم». جميع القيم المعروضة مستمدة من الافتراضات التي يمكنك تعديلها.';

  @override
  String get equipmentSelected => 'محددة';

  @override
  String get equipmentSelect => 'استخدام هذه الحزمة';

  @override
  String get equipmentCostLabel => 'تكلفة الحزمة';

  @override
  String get errorStorageUnavailable => 'تعذّر حفظ التغييرات على هذا الجهاز.';

  @override
  String get errorStorageCorrupted =>
      'تعذّرت قراءة السيناريو المحفوظ، لذا تم تحميل خط أساس الدراسة.';

  @override
  String get errorStorageUnsupported =>
      'أُنشئ السيناريو المحفوظ بواسطة إصدار أحدث من التطبيق.';

  @override
  String get errorImportInvalid => 'النص الملصق ليس JSON صالحًا لسيناريو.';

  @override
  String get errorGeneric => 'حدث خطأ ما.';

  @override
  String get assumptionsIntro =>
      'تُشتق جميع القيم في هذا التطبيق من القيم أدناه. عدّل أي قيمة وسيُعاد احتساب كل ما يعتمد عليها.';

  @override
  String get staffingReferenceTitle => 'مسجل في ملف العمل';

  @override
  String get staffingReferenceBody =>
      'يسجل ملف العمل المصدر أيضًا مراحل التوظيف وساعات العمل الأسبوعية (الموظف 1: 54 ساعة، الموظف 2: 42 ساعة، المؤسسون: 13 ساعة). لم يُذكر تعريفها، لذا تُحفظ هنا كمرجع ولا تدخل في أي عملية احتساب.';

  @override
  String get calculatedSectionTitle => 'مشتقة من هذه المدخلات';

  @override
  String get noResultsYet => 'لا توجد نتائج بعد';

  @override
  String get sectionInvestment => '????? ?????????';

  @override
  String get sectionFunding => '??? ????? ?????? ????????';

  @override
  String get sectionStress => '??????? / ????? ?????';

  @override
  String get fieldAnnualDiscountRate => '???? ????? ??????';

  @override
  String get fieldWorkingCapitalFixed => '??????? ??? ????? ??????';

  @override
  String get fieldOpeningDelayBuffer => '???? ????? ????????';

  @override
  String get fieldCriticalFailureStartMonth => '??? ??? ????? ?????';

  @override
  String get fieldCriticalFailureDowntimeDays => '???? ???? ????? ?????';

  @override
  String get helpAnnualDiscountRate =>
      '??????? ????? ?????? ??????? ????? ????????? ????????. ??????? ??? ???? ???? ??????? ??? 12.';

  @override
  String get helpWorkingCapitalFixed =>
      '??????? ???? ???????? ??? ??????? ???????. ??????? ??????? ?? ????????? ???? ??? ????????? ???? ?? ???? ????? ??????.';

  @override
  String get helpCriticalFailure =>
      'يكون التعطل الحرج معطلاً في الحالة الأساسية. تضبط هذه الحقول حدث الضغط.';

  @override
  String get enableCriticalFailure => 'تفعيل التعطل الحرج';

  @override
  String get additionalExpenses => 'مصروفات شهرية مخصصة';

  @override
  String get addExpense => 'إضافة مصروف';

  @override
  String get removeExpense => 'حذف المصروف';

  @override
  String get noAdditionalExpenses => 'لا توجد مصروفات مخصصة';

  @override
  String get expenseName => 'اسم المصروف';

  @override
  String get monthlyAmount => 'المبلغ الشهري';

  @override
  String get employeeRoster => 'قائمة الموظفين';

  @override
  String get addEmployee => 'إضافة موظف';

  @override
  String get editEmployee => 'تعديل الموظف';

  @override
  String get deleteEmployee => 'حذف الموظف';

  @override
  String get noEmployees => 'لا يوجد موظفون في القائمة';

  @override
  String get employeeName => 'اسم الموظف';

  @override
  String get founder => 'مؤسس (دون راتب)';

  @override
  String get fixedMonthlySalary => 'راتب شهري ثابت (اختياري)';

  @override
  String get weeklyShifts => 'ورديات الأسبوع';

  @override
  String get shifts => 'ورديات';

  @override
  String get addShift => 'إضافة وردية';

  @override
  String get weekday => 'يوم الأسبوع';

  @override
  String get startHour => 'ساعة البدء';

  @override
  String get endHour => 'ساعة الانتهاء';

  @override
  String get breakHours => 'ساعات الاستراحة';

  @override
  String get monday => 'الاثنين';

  @override
  String get tuesday => 'الثلاثاء';

  @override
  String get wednesday => 'الأربعاء';

  @override
  String get thursday => 'الخميس';

  @override
  String get friday => 'الجمعة';

  @override
  String get saturday => 'السبت';

  @override
  String get sunday => 'الأحد';

  @override
  String get payrollConfiguration => 'إعداد الرواتب';

  @override
  String get payrollMode => 'طريقة توزيع الرواتب';

  @override
  String get payrollFixed => 'ثابت لكل موظف';

  @override
  String get payrollProportional => 'متناسب مع الساعات';

  @override
  String get sharedPayrollBudget => 'ميزانية الرواتب الشهرية المشتركة';

  @override
  String get overtimeMultiplier => 'مضاعف الوقت الإضافي';

  @override
  String get regularHoursCap => 'حد الساعات الشهرية العادية (اختياري)';

  @override
  String get bonusConfiguration => 'إعداد المكافآت';

  @override
  String get bonusMode => 'طريقة المكافأة';

  @override
  String get bonusDisabled => 'معطلة';

  @override
  String get bonusExcessRevenue => 'نسبة من الإيراد الزائد';

  @override
  String get bonusFixedThreshold => 'مبلغ ثابت عند بلوغ الحد';

  @override
  String get revenueTarget => 'الإيراد المستهدف';

  @override
  String get thresholdMultiplier => 'مضاعف الحد (نقاط مئوية)';

  @override
  String get percentageOfExcess => 'نسبة الإيراد الزائد';

  @override
  String get fixedBonusAmount => 'مبلغ المكافأة الثابت';

  @override
  String get seasonalityNotice =>
      'يبقى الإشغال الأساسي مأخوذاً من جدول الإشغال. تضربه هذه العوامل فقط عند تفعيل الموسمية.';

  @override
  String get seasonalityDemand => 'عوامل الطلب';

  @override
  String get enableSeasonality => 'تفعيل الموسمية';

  @override
  String get weatherFactor => 'عامل طلب الطقس';

  @override
  String get marketingFactor => 'عامل طلب التسويق';

  @override
  String get monthFactors => 'عوامل الأشهر';

  @override
  String get dayFactors => 'عوامل أيام الأسبوع';

  @override
  String get seasonalityEvents => 'أحداث التقويم';

  @override
  String get addEvent => 'إضافة حدث';

  @override
  String get editEvent => 'تعديل الحدث';

  @override
  String get noEvents => 'لا توجد أحداث';

  @override
  String get eventName => 'اسم الحدث';

  @override
  String get startMonth => 'شهر البدء';

  @override
  String get endMonth => 'شهر الانتهاء';

  @override
  String get demandFactor => 'عامل الطلب';

  @override
  String get active => 'نشط';

  @override
  String get forecastingMode => 'وضع التوقع';

  @override
  String get forecastingModeOccupancy => 'مدفوع بالإشغال';

  @override
  String get forecastingModeMarketing => 'مدفوع بالتسويق';

  @override
  String get marketingForecastHint =>
      'يستبدل وضع التسويق جدول الإشغال عندما تنتج مدخلاته طلباً. وتظل الموسمية تضرب الإشغال الناتج، بينما تعود المدخلات الصفرية إلى جدول الإشغال.';

  @override
  String get monthlyMarketingBudget => 'ميزانية التسويق الشهرية';

  @override
  String get marketingReach => 'عدد الأشخاص الذين يتم الوصول إليهم شهرياً';

  @override
  String get marketingConversionRate => 'معدل التحويل';

  @override
  String get averageRoundsPerCustomer => 'متوسط الجولات لكل عميل محوّل';

  @override
  String get useWeeklyOperatingHours => 'استخدام ساعات تشغيل أسبوعية';

  @override
  String get weeklyOperatingHoursHint =>
      'حدد ساعات كل يوم. يمكن أن تكون الخميس والجمعة والسبت أطول.';

  @override
  String get equipmentLifecycle => 'دورة حياة المعدات';

  @override
  String get equipmentLifecycleHint =>
      'خطط للاحتياطيات والاستبدال الاختياري؛ لا يمثل ذلك توقعاً لتعطل إجباري.';

  @override
  String get usefulLifeMonths => 'العمر النافع';

  @override
  String get replacementCost => 'تكلفة الاستبدال المخطط';

  @override
  String get replacementCostHint =>
      'اتركها صفراً لاستخدام تكلفة الحزمة المحددة حالياً.';

  @override
  String get monthlyMaintenanceReserve => 'احتياطي الصيانة الشهري';

  @override
  String get sparePartsReserve => 'احتياطي قطع الغيار الشهري';

  @override
  String get includePlannedReplacement => 'تضمين الاستبدال المخطط في التوقعات';

  @override
  String get plannedReplacementHint =>
      'يضيف تدفقاً استثمارياً خارجاً لمرة واحدة في شهر العمر النافع المقرّب.';

  @override
  String get navActuals => '??????';

  @override
  String get actualsTitle => '?????? ????? ???????';

  @override
  String get actualsIntro =>
      '???? ??????? ???????? ????? ???????. ???????? = ?????? - ???????. ?????? ??? ?????? ???? ?????.';

  @override
  String get actualsAddMonth => '????? ???? ????';

  @override
  String actualsEditMonth(Object month) {
    return '????? ??? $month';
  }

  @override
  String get actualsRevenue => '??????? ??????';

  @override
  String get actualsExpenses => '????????? ????????? ???????';

  @override
  String get actualsClearAll => '??? ?? ??????';

  @override
  String get actualsClearMonth => '?????';

  @override
  String get actualsEmpty => '?? ???? ?????? ????? ???.';

  @override
  String get actualsVariance => '????????';

  @override
  String get actualsForecast => '???????';

  @override
  String get actualsActual => '??????';

  @override
  String get sectionDebt => '????? ??????';

  @override
  String get enableDebt => '????? ????? ??????';

  @override
  String get fieldDebtPrincipal => '??? ?????';

  @override
  String get fieldDebtInterestRate => '???? ??????? ??????';

  @override
  String get fieldDebtTermMonths => '????? (????)';

  @override
  String get fieldDebtFirstPaymentMonth => '??? ??? ???';

  @override
  String get fieldDebtDisbursementMonth => '??? ?????';

  @override
  String get fieldDebtKind => '???? ??????';

  @override
  String get debtKindAnnuity => '??? ???? (?????? ?????)';

  @override
  String get debtKindInterestOnly => '????? ??? (??? ?? ???????)';

  @override
  String get debtHelp =>
      '???? ????? ???? ??? ?????? ?????? ?? ??? ????? ????????. ?????? ????????? ?????? ??? ?? ??????.';
}
