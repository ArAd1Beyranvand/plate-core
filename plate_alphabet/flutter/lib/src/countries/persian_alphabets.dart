import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// Persian alphabets for Iranian plate slots. Digits are shared via
/// [PlateAlphabetDigits.iranian]; letters live here because plate rules
/// constrain them.
///
/// [privateLetters] is the thirteen-letter series a private plate picks from.
/// Every other class has a fixed letter, so it gets a one-character alphabet:
/// `chosen` rather than `typed`, so the user cannot clear the letter.
abstract final class PersianAlphabets {
  static const PlateAlphabet digits = PlateAlphabetDigits.iranian;

  /// The thirteen letters a private plate's series can be. Every other letter
  /// is reserved to one non-private class; offering it here would let a user
  /// build a private plate that cannot legally exist.
  static const PlateAlphabet privateLetters = PlateAlphabet.pattern(
    id: 'fa.privateLetters',
    include: 'ب ج د س ص ط ق ل م ن و ه ی',
    input: AlphabetInput.chosen,
    isNumeric: false,
    direction: TextDirection.rtl,
    placeholder: '؟',
  );

  /// Every series letter of the civil blank, for the spec whose livery follows
  /// its letter: [privateLetters], each class's fixed letter, `ژ` (printed
  /// `♿︎`, see [disabledSymbol]) and Latin `D`, `S`.
  static const PlateAlphabet civilLetters = PlateAlphabet.pattern(
    id: 'fa.civilLetters',
    include: 'ب ج د س ص ط ق ل م ن و ه ی ت ع ک الف گ پ ث ش ز ف ژ D S',
    input: AlphabetInput.chosen,
    isNumeric: false,
    direction: TextDirection.rtl,
    placeholder: '؟',
    glyphs: {'ژ': '♿︎'},
  );

  /// The wheelchair symbol ♿︎ a disabled driver's plate carries in place of a
  /// county letter. Stored as `ژ`, the police database's placeholder, so a
  /// plate read back matches the registry.
  static const PlateAlphabet disabledSymbol = PlateAlphabet(
    id: 'fa.disabledSymbol',
    characters: ['ژ'],
    input: AlphabetInput.chosen,
    isNumeric: false,
    direction: TextDirection.rtl,
    placeholder: '♿︎',
    glyphs: {'ژ': '♿︎'},
  );

  // One alphabet per fixed-letter class, written out because a `const` value
  // cannot come from a function call.

  /// `ت`, for تاکسی (taxi). The Latin word TAXI is a [PlateLabel], not a value.
  static const PlateAlphabet taxiLetter = PlateAlphabet(
    id: 'fa.taxiLetter',
    characters: ['ت'],
    input: AlphabetInput.chosen,
    isNumeric: false,
    direction: TextDirection.rtl,
    placeholder: '؟',
  );

  /// `ع`, for عمومی — public transport.
  static const PlateAlphabet publicLetter = PlateAlphabet(
    id: 'fa.publicLetter',
    characters: ['ع'],
    input: AlphabetInput.chosen,
    isNumeric: false,
    direction: TextDirection.rtl,
    placeholder: '؟',
  );

  /// `ک`, for کشاورزی — agricultural vehicles.
  static const PlateAlphabet agriculturalLetter = PlateAlphabet(
    id: 'fa.agriculturalLetter',
    characters: ['ک'],
    input: AlphabetInput.chosen,
    isNumeric: false,
    direction: TextDirection.rtl,
    placeholder: '؟',
  );

  // TODO(py): [H7] one slot value of three code points (الف); restriction counts values, not len(). RTL: H10.
  // TODO(ts): [H7] value length is 3 code units but one slot; never use .length to decide fullness.
  // TODO(kt): [H7] value length is 3 chars but one slot; never use length to decide fullness.
  /// `الف`, how a government plate prints its letter: three code points, one
  /// plate position.
  static const PlateAlphabet governmentLetter = PlateAlphabet(
    id: 'fa.governmentLetter',
    characters: ['الف'],
    input: AlphabetInput.chosen,
    isNumeric: false,
    direction: TextDirection.rtl,
    placeholder: '؟',
  );

  /// `پ`, for پلیس — FARAJA police.
  static const PlateAlphabet policeLetter = PlateAlphabet(
    id: 'fa.policeLetter',
    characters: ['پ'],
    input: AlphabetInput.chosen,
    isNumeric: false,
    direction: TextDirection.rtl,
    placeholder: '؟',
  );

  /// `ث` — IRGC (Army Police).
  static const PlateAlphabet irgcLetter = PlateAlphabet(
    id: 'fa.irgcLetter',
    characters: ['ث'],
    input: AlphabetInput.chosen,
    isNumeric: false,
    direction: TextDirection.rtl,
    placeholder: '؟',
  );

  /// `ش` — Islamic Republic of Iran Army.
  static const PlateAlphabet armyLetter = PlateAlphabet(
    id: 'fa.armyLetter',
    characters: ['ش'],
    input: AlphabetInput.chosen,
    isNumeric: false,
    direction: TextDirection.rtl,
    placeholder: '؟',
  );

  /// `ز` — Ministry of Defence and Armed Forces Logistics.
  static const PlateAlphabet defenceLetter = PlateAlphabet(
    id: 'fa.defenceLetter',
    characters: ['ز'],
    input: AlphabetInput.chosen,
    isNumeric: false,
    direction: TextDirection.rtl,
    placeholder: '؟',
  );

  /// `ف` — General Staff of the Armed Forces.
  static const PlateAlphabet generalStaffLetter = PlateAlphabet(
    id: 'fa.generalStaffLetter',
    characters: ['ف'],
    input: AlphabetInput.chosen,
    isNumeric: false,
    direction: TextDirection.rtl,
    placeholder: '؟',
  );

  /// `گ` — temporary passage, the plate a newly built car wears.
  static const PlateAlphabet temporaryLetter = PlateAlphabet(
    id: 'fa.temporaryLetter',
    characters: ['گ'],
    input: AlphabetInput.chosen,
    isNumeric: false,
    direction: TextDirection.rtl,
    placeholder: '؟',
  );

  /// Latin `D` — diplomatic and consular corps; reads LTR.
  static const PlateAlphabet politicalLetter = PlateAlphabet(
    id: 'fa.politicalLetter',
    characters: ['D'],
    input: AlphabetInput.chosen,
    isNumeric: false,
    placeholder: '?',
  );

  /// Latin `S` — international-organisation service plates.
  static const PlateAlphabet serviceLetter = PlateAlphabet(
    id: 'fa.serviceLetter',
    characters: ['S'],
    input: AlphabetInput.chosen,
    isNumeric: false,
    placeholder: '?',
  );
}
