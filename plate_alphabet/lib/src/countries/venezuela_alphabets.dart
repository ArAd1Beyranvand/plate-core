import 'package:plate_core/plate_core.dart';

/// The alphabets of a 2008 plate: six serial cells that take a letter or a
/// digit, then the state letter, and the state name echoed under the serial.
abstract final class VenezuelaAlphabets {
  /// The first six cells. Which of them are letters depends on the vehicle
  /// category (`AB123CD` for a private car, `AB1C23D` for a motorcycle, ...),
  /// so the cells take either and `VenezuelaValidator` judges the pattern.
  static const PlateAlphabet serial = PlateAlphabet.pattern(
    id: 've.serial',
    include: 'A-Z 0-9',
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// The state each last letter stands for, as the plate prints it: upper
  /// case, unaccented. Q is not assigned, and Z is used for signalling but
  /// names no state. W is printed VARGAS, the state's name when the code was
  /// assigned; it is La Guaira since 2019.
  static const Map<String, String> stateNames = <String, String>{
    'A': 'DISTRITO CAPITAL',
    'B': 'ANZOATEGUI',
    'C': 'APURE',
    'D': 'ARAGUA',
    'E': 'BARINAS',
    'F': 'BOLIVAR',
    'G': 'CARABOBO',
    'H': 'COJEDES',
    'I': 'FALCON',
    'J': 'GUARICO',
    'K': 'LARA',
    'L': 'MERIDA',
    'M': 'MIRANDA',
    'N': 'MONAGAS',
    'O': 'NUEVA ESPARTA',
    'P': 'PORTUGUESA',
    'R': 'SUCRE',
    'S': 'TACHIRA',
    'T': 'TRUJILLO',
    'U': 'YARACUY',
    'V': 'ZULIA',
    'W': 'VARGAS',
    'X': 'AMAZONAS',
    'Y': 'DELTA AMACURO',
  };

  /// The last cell: a state code.
  static const PlateAlphabet state = PlateAlphabet.pattern(
    id: 've.state',
    include: 'A-Y',
    exclude: 'Q',
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// [state] rendered as the name it stands for — the alphabet the caption
  /// under the serial mirrors the last cell through.
  static const PlateAlphabet stateName = PlateAlphabet.pattern(
    id: 've.stateName',
    include: 'A-Y',
    exclude: 'Q',
    input: AlphabetInput.typed,
    isNumeric: false,
    glyphs: stateNames,
  );
}
