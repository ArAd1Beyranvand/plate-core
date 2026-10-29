/// What a plate is licensed for; drives colour via `PSThemes.forUsage`. Legacy
/// and Gaza plates encode it in trailing digits; modern West Bank plates do not,
/// so the host supplies it.
enum PSUsage {
  /// Ordinary car (legacy 40–49, 90–98; default elsewhere). Green on white.
  private,

  /// Leased vehicle (legacy 32). Green on white (same visual as private).
  leased,

  /// Taxi, service, bus (legacy 30). White on green — only inverted West Bank usage.
  publicTransport,

  /// Government vehicles (legacy 99). Red on white.
  government,

  /// Duty-exempt: ambulance, fire, civil defence (legacy 31). Red on white.
  exempt,

  /// Police (modern scheme only). Green on white.
  police,

  /// Dealer/inspection plate (different design: PSWestBankPlates.modernTrade). White on blue.
  tradePlate,

  /// Commercial/trucks (Gaza only, codes 10–19). Not in West Bank schemes.
  commercial,

  /// Municipality vehicles (Gaza only, codes 40–49).
  municipality,
}

// TODO(py): [H9] Python re: \d/\w match Unicode; keep explicit [0-9]/[A-Z] classes (or re.ASCII).
// TODO(ts): [H9] same flavour as Dart; port as is, cover accept/reject in the vectors (D9).
// TODO(kt): [H9] Regex engine differs per target (JVM/JS/Native): keep to portable syntax.
final _twoDigits = RegExp(r'^\d\d$');

/// Legacy West Bank usage classes (1994–July 2018), keyed by trailing digits.
abstract final class PSLegacyUsage {
  /// [code] is a string, since '07' ≠ '7'. Null if not issued.
  static PSUsage? forCode(String code) {
    if (!_twoDigits.hasMatch(code)) return null;
    return switch (int.parse(code)) {
      >= 40 && <= 49 || >= 90 && <= 98 => PSUsage.private,
      99 => PSUsage.government,
      30 => PSUsage.publicTransport,
      31 => PSUsage.exempt,
      32 => PSUsage.leased,
      _ => null,
    };
  }

  static const List<String> codes = [
    '30', '31', '32', //
    '40', '41', '42', '43', '44', '45', '46', '47', '48', '49', //
    '90', '91', '92', '93', '94', '95', '96', '97', '98', '99', //
  ];

  /// Legacy district codes. Before/after 1995 is the registration date, not the
  /// place: 4 and 7 are the same territory.
  static const Map<String, String> districts = {
    '1': 'Gaza Strip, registered before 1995',
    '3': 'Gaza Strip, registered after 1995',
    '4': 'Northern West Bank, before 1995',
    '7': 'Northern West Bank, after 1995',
    '5': 'Central West Bank, before 1995',
    '6': 'Central West Bank, after 1995',
    '8': 'Southern West Bank (Bethlehem, Hebron), before 1995',
    '9': 'Southern West Bank (Bethlehem, Hebron), after 1995',
  };

  static const List<String> districtCodes = [
    '1', '3', '4', '5', '6', '7', '8', '9', //
  ];
}

/// Gaza usage classes, keyed by trailing digits; they drive glyph colour only.
abstract final class PSGazaUsage {
  /// Null if unallocated (30–39, 60–99). The code space is unrelated to
  /// [PSLegacyUsage]'s.
  static PSUsage? forCode(String code) {
    if (!_twoDigits.hasMatch(code)) return null;
    return switch (int.parse(code)) {
      <= 9 => PSUsage.private,
      <= 19 => PSUsage.commercial,
      <= 29 => PSUsage.publicTransport,
      >= 40 && <= 49 => PSUsage.municipality,
      >= 50 && <= 59 => PSUsage.government,
      _ => null,
    };
  }

  static List<String> get codes => [
    for (var n = 0; n <= 29; n++) n.toString().padLeft(2, '0'),
    for (var n = 40; n <= 59; n++) n.toString().padLeft(2, '0'),
  ];
}
