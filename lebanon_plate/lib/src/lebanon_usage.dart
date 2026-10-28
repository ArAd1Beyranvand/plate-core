/// The field colour of a Lebanese plate, independent of [LebanonLetter]: one
/// enum for both would be full of unissued combinations.
enum LebanonUsage {
  /// Privately owned vehicles, and letter-coded classes without a colour:
  /// judicial (J), religious (R), parliament (MP), motorcycle (M).
  private(arabic: 'خصوصي', latin: 'PRIVATE', letter: null),

  consular(arabic: null, latin: 'CONSULAR', letter: 'C'),

  diplomatic(arabic: null, latin: 'DIPLOMATIC', letter: 'D'),

  publicInstitution(arabic: 'مؤسسات', latin: 'PUBLIC', letter: 'M'),

  /// Inherits red from its former `M` classification; the current field
  /// colour is unattested.
  // TODO(p-plate): source the field colour of current P plates
  publicTransport(arabic: null, latin: 'PUBLIC TRANSPORT', letter: 'P'),

  drivingSchool(arabic: null, latin: 'DRIVING SCHOOL', letter: 'M'),

  transit(arabic: null, latin: 'TRANSIT', letter: null),

  temporary(arabic: null, latin: 'TEMPORARY', letter: null),

  tourism(arabic: null, latin: 'TOURISM', letter: null);

  const LebanonUsage({
    required this.arabic,
    required this.latin,
    required this.letter,
  });

  /// The Arabic word printed in the band, or null when no source names one.
  /// Null means "not attested", not "blank by rule"; nothing is printed rather
  /// than a guess.
  final String? arabic;

  /// Label for host UI, not plate text.
  final String latin;

  /// The fixed letter for this class, if any. Null for [private] (the letter
  /// is the town) and for unattested classes. [publicInstitution] and
  /// [drivingSchool] both carry `M`.
  final String? letter;

  bool get isWhite => this == LebanonUsage.private;

  static const Set<LebanonUsage> coloured = <LebanonUsage>{
    consular,
    diplomatic,
    publicInstitution,
    publicTransport,
    drivingSchool,
    transit,
    temporary,
    tourism,
  };
}
