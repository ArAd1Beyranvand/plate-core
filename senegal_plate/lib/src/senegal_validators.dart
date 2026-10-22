import 'package:plate_core/plate_core.dart';

/// Judges a Senegalese plate field by field: the 1989–2019 `DK-1234-AB`, the
/// current `AA-123-BC [DK / 01]`. Quiet until the last field has something in
/// it. Reports, never bars a keystroke.
class SenegalValidator extends PlateValidator {
  const SenegalValidator();

  /// The regional codes: Dakar, Diourbel, Fatick, Kaffrine, Kaolack,
  /// Kédougou, Kolda, Louga, Matam, Saint-Louis, Sédhiou, Tambacounda, Thiès,
  /// Ziguinchor.
  static const Set<String> regions = <String>{
    'DK',
    'DB',
    'FK',
    'KA',
    'KL',
    'KE',
    'KD',
    'LG',
    'MT',
    'SL',
    'SE',
    'TC',
    'TH',
    'ZG',
  };

  static final RegExp _letters2 = RegExp(r'^[A-Z]{2}$');
  static final RegExp _letters1or2 = RegExp(r'^[A-Z]{1,2}$');
  static final RegExp _digits2 = RegExp(r'^[0-9]{2}$');
  static final RegExp _digits3 = RegExp(r'^[0-9]{3}$');
  static final RegExp _digits4 = RegExp(r'^[0-9]{4}$');

  @override
  PlateValidation validate(PlateEntry entry) {
    final PlateValidation? refused = restrictionVerdict(entry);
    if (refused != null) return refused;
    final List<PlateTextGroup> groups = entry.spec.textGroups;
    if (groups.isEmpty || entry.group(groups.last.key!).isEmpty) {
      return const PlateValidation.valid();
    }
    final bool old = entry.spec.id == 'sn.old';
    for (final PlateTextGroup g in groups) {
      final String value = entry.group(g.key!);
      final (RegExp, String)? rule = switch (g.key) {
        'number' when old => (_digits4, 'The number is 4 digits.'),
        'number' => (_digits3, 'The number is 3 digits.'),
        'letters' when old => (_letters1or2, 'The closing series is 1 or 2 letters.'),
        'letters' => (_letters2, 'The closing series is 2 letters.'),
        'series' => (_letters2, 'The series is 2 letters.'),
        'department' => (_digits2, 'The department is 2 digits.'),
        _ => null,
      };
      if (rule != null && !rule.$1.hasMatch(value)) {
        return PlateValidation.invalid(rule.$2);
      }
    }
    if (!regions.contains(entry.group('region'))) {
      return const PlateValidation.invalid('Unknown regional code.');
    }
    return const PlateValidation.valid();
  }
}
