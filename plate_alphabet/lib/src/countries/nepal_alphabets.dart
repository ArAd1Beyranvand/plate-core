import 'package:plate_core/plate_core.dart';

/// The alphabets behind Nepali slots.
///
/// The plates issued since 2020 print Latin capitals and Western digits: a
/// province name, a vehicle class (`A`–`K`, with a digit for the sub-classes
/// `C1`, `H2`, `J5`...), two series letters and four digits. The 1983–2019
/// plates print Devanagari: [devanagariDigits] stores `0-9` and prints
/// `०-९`; [zone] is the 14 zone codes the article lists and [legacyClass] the
/// class letters of its category table, both picked a symbol at a time.
abstract final class NepalAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  /// The class code after the province: `A`–`K`, then `1`–`5` for the
  /// sub-class digit (`C1`, `I3`, `J5`).
  static const PlateAlphabet vehicleClass = PlateAlphabet.pattern(
    id: 'np.class',
    include: 'A-K 1-5',
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// The seven provinces, upper case as printed above the number. A symbol is
  /// the whole name.
  static const PlateAlphabet province = PlateAlphabet.pattern(
    id: 'np.province',
    include: 'KOSHI MADHESH BAGMATI GANDAKI LUMBINI KARNALI SUDURPASHCHIM',
    input: AlphabetInput.chosen,
    isNumeric: false,
    placeholder: '—',
  );

  static const Map<String, String> _devanagariNumerals = <String, String>{
    '0': '०', '1': '१', '2': '२', '3': '३', '4': '४', //
    '5': '५', '6': '६', '7': '७', '8': '८', '9': '९',
  };

  static const PlateAlphabet devanagariDigits = PlateAlphabet.pattern(
    id: 'np.devanagari.digits',
    include: '0-9',
    input: AlphabetInput.typed,
    isNumeric: true,
    glyphs: _devanagariNumerals,
  );

  /// The zone codes of the 1983–2019 plates: Mechi, Kosi, Sagarmatha,
  /// Janakpur, Bagmati, Narayani, Gandaki, Lumbini, Dhawalagiri, Rapti, Bheri,
  /// Karnali, Seti, Mahakali.
  static const PlateAlphabet zone = PlateAlphabet.pattern(
    id: 'np.zone',
    include: 'मे को स ज बा ना ग लु ध रा भे क से म',
    input: AlphabetInput.chosen,
    isNumeric: false,
    placeholder: '—',
  );

  /// The class letters of the article's category table: private क च प,
  /// public ख ज फ, government ग झ ब, national corporation घ ञ, tourist य.
  static const PlateAlphabet legacyClass = PlateAlphabet.pattern(
    id: 'np.legacy.class',
    include: 'क ख ग घ च ज झ ञ प फ ब य',
    input: AlphabetInput.chosen,
    isNumeric: false,
    placeholder: '—',
  );
}
