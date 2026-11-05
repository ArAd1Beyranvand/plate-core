/// The closed set of governorate codes, 1 to 22, a 1993 northern plate carries
/// in its upper register. `YemenNorthernValidator` enforces that range and
/// nothing more.
enum YemenGovernorate {
  /// The capital municipality, distinct from [sanaaGovernorate].
  sanaaCity(1, 'Sanaa (City)', 'أمانة العاصمة', underHouthiControl: true),
  sanaaGovernorate(2, 'Sanaa (Governorate)', 'صنعاء', underHouthiControl: true),
  aden(3, 'Aden', 'عدن', underHouthiControl: false),
  taiz(4, 'Taiz', 'تعز', underHouthiControl: false),
  hadhramaut(5, 'Hadhramaut', 'حضرموت', underHouthiControl: false),
  alHudaydah(6, 'Al Hudaydah', 'الحديدة', underHouthiControl: true),
  ibb(7, 'Ibb', 'إب', underHouthiControl: true),
  hajjah(8, 'Hajjah', 'حجة', underHouthiControl: true),
  dhamar(9, 'Dhamar', 'ذمار', underHouthiControl: true),
  saada(10, 'Saada', 'صعدة', underHouthiControl: true),
  abyan(11, 'Abyan', 'أبين', underHouthiControl: false),
  lahij(12, 'Lahij', 'لحج', underHouthiControl: false),
  alBayda(13, 'Al Bayda', 'البيضاء', underHouthiControl: true),
  alMahwit(14, 'Al Mahwit', 'المحويت', underHouthiControl: true),
  shabwah(15, 'Shabwah', 'شبوة', underHouthiControl: false),
  marib(16, 'Marib', 'مأرب', underHouthiControl: false),
  alMahrah(17, 'Al Mahrah', 'المهرة', underHouthiControl: false),
  alJawf(18, 'Al Jawf', 'الجوف', underHouthiControl: true),
  amran(19, 'Amran', 'عمران', underHouthiControl: true),
  dhale(20, 'Dhale', 'الضالع', underHouthiControl: false),
  raymah(21, 'Raymah', 'ريمة', underHouthiControl: true),
  socotra(22, 'Socotra', 'سقطرى', underHouthiControl: false);

  const YemenGovernorate(
    this.code,
    this.englishName,
    this.arabicName, {
    required this.underHouthiControl,
  });

  final int code;
  final String englishName, arabicName;

  /// Whether the governorate lies where the 1993 northern format is current.
  /// Advisory and coarse, never enforced: control of Taiz, Al Jawf, Hadhramaut
  /// and Marib is split, and northern plates circulate outside the north. Use it
  /// to sort, caption or warn, not to refuse a plate.
  // TODO(control-map): a consumer who needs current control should carry its own map.
  final bool underHouthiControl;

  /// The governorate with [code], or null outside 1..22 (including half-typed
  /// input such as the `0` of `07`).
  static YemenGovernorate? fromCode(int code) =>
      values.where((g) => g.code == code).firstOrNull;

  /// The governorate the register [digits] name, zero-padded or bare, or null if
  /// non-numeric or outside 1..22.
  static YemenGovernorate? fromDigits(String digits) {
    final parsed = int.tryParse(digits);
    return parsed == null ? null : fromCode(parsed);
  }

  static const int minCode = 1;

  static const int maxCode = 22;
}
