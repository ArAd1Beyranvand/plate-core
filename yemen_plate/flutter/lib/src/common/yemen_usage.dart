/// What a Yemeni plate says the vehicle is for. System A issues `police`,
/// System B `military`; filter with [onUnified] and [onNorthern]. The labels are
/// the plate's own text, and [forHire] spells its Arabic word differently on
/// each system.
enum YemenUsage {
  private(
    unifiedArabic: 'خصوصي',
    unifiedLatin: 'PRIV.',
    northernArabic: 'خصوصي',
  ),

  /// Taxis and buses.
  forHire(unifiedArabic: 'أجرة', unifiedLatin: 'TAXI', northernArabic: 'اجرة'),

  /// Goods vehicles.
  transport(
    unifiedArabic: 'نقل',
    unifiedLatin: 'TRANS.',
    northernArabic: 'نقل',
  ),

  /// State-owned vehicles; no source names the northern Arabic word.
  // TODO(northern-labels): source the Arabic usage word on northern green plate.
  government(
    unifiedArabic: 'حكومي',
    unifiedLatin: 'GOV.',
    northernArabic: null,
  ),

  /// Police vehicles. System A only.
  police(unifiedArabic: 'شرطة', unifiedLatin: 'POLICE', northernArabic: null),

  /// Military vehicles, System B only, in the two [YemenMilitaryStyle] printings.
  /// No source names the word.
  // TODO(northern-labels): source the Arabic usage word on northern military plate.
  military(unifiedArabic: null, unifiedLatin: null, northernArabic: null);

  const YemenUsage({
    required this.unifiedArabic,
    required this.unifiedLatin,
    required this.northernArabic,
  });

  /// Arabic line on a System A plate; null if System A does not issue the usage.
  final String? unifiedArabic;

  /// Latin line on a System A plate; null if System A does not issue the usage.
  final String? unifiedLatin;

  /// Usage word on a System B plate; null if not issued or unsourced.
  final String? northernArabic;

  /// System A (2026 unified) issues this usage.
  bool get onUnified => unifiedLatin != null;

  /// System B (1993 northern) issues this usage. [northernArabic] cannot tell:
  /// it is null for some usages the north does issue.
  bool get onNorthern => this != YemenUsage.police;

  /// The usages a System A plate can carry.
  static const Set<YemenUsage> unified = <YemenUsage>{
    private,
    forHire,
    transport,
    government,
    police,
  };

  /// The usages a System B plate can carry.
  static const Set<YemenUsage> northern = <YemenUsage>{
    private,
    forHire,
    transport,
    government,
    military,
  };
}

/// The two military printings, which differ only in colour; chosen through
/// [YemenThemes.forNorthernUsage]'s `style`.
enum YemenMilitaryStyle { classic, modern }
