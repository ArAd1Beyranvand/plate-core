import 'package:plate_core/plate_core.dart';

/// Alphabets of an Armenian plate, and when each letter became legal.
///
/// Plates print Latin letters. The 1996 system opened with four chosen for
/// shape (`Լ`/`L`, `Ս`/`U`, `Տ`/`S`, `Օ`/`O`), so an Armenian and a foreigner
/// each read their own script; every letter added since is plain Latin and by
/// 2019 all twenty-six were in use. [letters] therefore has no
/// [PlateAlphabet.glyphs]. Only the military plate prints Armenian script, via
/// [militaryClass].
abstract final class ArmeniaAlphabets {
  /// The two letters of a civilian number: all twenty-six, under an `am.` id so
  /// they sit beside the class alphabets.
  ///
  /// Which letters may appear on a civilian plate is a validator's question
  /// (see [stateVehiclesOnly]): barring `G` here would make the rule
  /// un-typeable instead of reportable.
  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'am.letters',
    include: 'A-Z',
  );

  /// Diplomatic class: `D` for a diplomat, `T` for a technician. A separate
  /// vocabulary from [letters], not a subset: `D` here names the accreditation.
  static const PlateAlphabet diplomaticClass = PlateAlphabet(
    id: 'am.diplomaticClass',
    characters: <String>['D', 'T'],
    input: AlphabetInput.chosen,
  );

  /// The country code a diplomatic plate ends with: `AM`, or `ARM` on newer
  /// plates.
  static const PlateAlphabet diplomaticCountry = PlateAlphabet(
    id: 'am.diplomaticCountry',
    characters: <String>['AM', 'ARM'],
    input: AlphabetInput.chosen,
  );

  /// Bus class: `S` city bus, `L` long-range coach.
  static const PlateAlphabet busClass = PlateAlphabet(
    id: 'am.busClass',
    characters: <String>['S', 'L'],
    input: AlphabetInput.chosen,
  );

  /// Ministry of Defence class, stored as ASCII `M` and `T` and rendered `Մ`
  /// (passenger) and `Տ` (transport). Chosen, since neither is on a keyboard.
  static const PlateAlphabet militaryClass = PlateAlphabet(
    id: 'am.militaryClass',
    characters: <String>['M', 'T'],
    input: AlphabetInput.chosen,
    glyphs: <String, String>{
      'M': 'Մ', // մարդատար — passenger
      'T': 'Տ', // տրանսպորտ — transport
    },
  );

  /// Letters issued only to the state: `G` and `I` (2015), for the Police and
  /// Prosecutor's office, always doubled. Who may hold a number is a validator
  /// rule, so this is data for `ArmeniaPlateValidator`.
  static const Set<String> stateVehiclesOnly = <String>{'G', 'I'};

  /// When each letter entered general civilian use, as year and month. Where
  /// a letter was first sold for a fee, the later general date is recorded.
  /// `G` and `I` carry their 2015 state-only date; see [stateVehiclesOnly].
  ///
  /// Months, not [DateTime]s, which cannot be `const`.
  static const Map<String, (int year, int month)> introduced =
      <String, (int, int)>{
        'L': (1996, 1),
        'U': (1996, 1), // Ս
        'S': (1996, 1), // Տ
        'O': (1996, 1), // Օ
        'P': (2008, 12),
        'D': (2012, 7),
        'N': (2012, 7),
        'T': (2012, 7),
        'V': (2012, 7),
        'A': (2012, 5),
        'M': (2012, 5),
        'Q': (2012, 5),
        'R': (2012, 5),
        'C': (2013, 10),
        'F': (2013, 10),
        'Z': (2013, 10),
        'G': (2015, 1),
        'I': (2015, 1),
        'X': (2016, 1),
        'B': (2017, 1),
        'H': (2017, 1),
        'J': (2018, 1),
        'W': (2019, 1),
        'Y': (2019, 1),
        'K': (2019, 1),
        'E': (2019, 1),
      };

  /// Whether [letter] (case-insensitive) was issued by [month] of [year].
  /// [month] defaults to December: the letters in use by the end of that year.
  static bool inUseOn(String letter, int year, {int month = 12}) {
    final start = introduced[letter.toUpperCase()];
    if (start == null) return false;
    return year > start.$1 || (year == start.$1 && month >= start.$2);
  }
}
