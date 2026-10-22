import 'dart:math';

import 'package:plate_core/plate_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yemen_plate/yemen_plate.dart';

/// Every spec this package declares: a car and a motorcycle per system. A
/// usage is a `PlateCountry` and a `PlateTheme` the host hands to the canvas.
Iterable<PlateSpec> get _allSpecs sync* {
  yield* _unifiedSpecs;
  yield* _northernSpecs;
}

Iterable<PlateSpec> get _unifiedSpecs sync* {
  yield YemenUnifiedPlates.car;
  yield YemenUnifiedPlates.moto;
}

Iterable<PlateSpec> get _northernSpecs sync* {
  yield YemenNorthernPlates.car;
  // ignore: deprecated_member_use_from_same_package
  yield YemenNorthernPlates.moto;
}

/// The single slot of [spec]'s group named [key].
PlateSlot _field(PlateSpec spec, String key) =>
    spec.slots[spec.effectiveTextGroups
        .firstWhere((PlateTextGroup g) => g.key == key)
        .indices
        .single];

void main() {
  group('debugValidateSpec', () {
    for (final PlateSpec spec in _allSpecs) {
      test(spec.id, () {
        // debugValidateSpec is assert-only and always returns true; the
        // assertion itself is what fails a spec with a slot outside its
        // canvas, a mirror pointing at no slot, or an unevenly pitched
        // register.
        var ok = false;
        assert(ok = debugValidateSpec(spec));
        expect(ok, isTrue, reason: 'assertions must be enabled to run this test');
      });
    }
  });

  group('ids', () {
    test('are unique across both systems', () {
      final List<String> ids = <String>[for (final s in _allSpecs) s.id];
      expect(ids.toSet().length, ids.length);
    });

    test('carry no usage segment', () {
      // The whole phase, as an assertion: a spec is a geometry, so its id
      // names one. `ye.northern.car`, never `....private`.
      for (final PlateSpec spec in _allSpecs) {
        expect(
          YemenUsage.values.any((YemenUsage u) => spec.id.contains(u.name)),
          isFalse,
          reason: spec.id,
        );
      }
    });
  });

  group('text groups carry the keys the validators read', () {
    test('System A: number + sideCode', () {
      for (final PlateSpec spec in _unifiedSpecs) {
        final Set<String?> keys = <String?>{
          for (final PlateTextGroup g in spec.effectiveTextGroups) g.key,
        };
        expect(keys, containsAll(<String>['number', 'sideCode']), reason: spec.id);
      }
    });

    test('System B: governorate + serial', () {
      for (final PlateSpec spec in _northernSpecs) {
        final Set<String?> keys = <String?>{
          for (final PlateTextGroup g in spec.effectiveTextGroups) g.key,
        };
        expect(keys, containsAll(<String>['governorate', 'serial']), reason: spec.id);
      }
    });
  });

  group('fields are single slots with a min and max length', () {
    test('System A: number 4..6, side code 2', () {
      for (final PlateSpec spec in _unifiedSpecs) {
        expect(spec.slots.length, 2, reason: spec.id);
        final number = _field(spec, 'number');
        expect((number.minLength, number.length), (4, 6), reason: spec.id);
        final sideCode = _field(spec, 'sideCode');
        expect((sideCode.minLength, sideCode.length), (2, 2), reason: spec.id);
      }
    });

    test('System B: governorate 1..2, serial 4..6, one echo per field', () {
      for (final PlateSpec spec in _northernSpecs) {
        expect(spec.slots.length, 2, reason: spec.id);
        final gov = _field(spec, 'governorate');
        expect((gov.minLength, gov.length), (1, 2), reason: spec.id);
        final serial = _field(spec, 'serial');
        expect((serial.minLength, serial.length), (4, 6), reason: spec.id);
        expect(spec.mirrors.length, 2, reason: spec.id);
      }
    });

    test('a short value completes once every field reaches its minimum', () {
      final controller = PlateController.fromValues(YemenNorthernPlates.car, ['7', '123']);
      expect(controller.isCompleted, isFalse);
      controller.setAt(1, '1234');
      expect(controller.isCompleted, isTrue);
      controller.dispose();
    });
  });

  group('generator round-trip', () {
    // The strongest available proof that no group key and no slot order moved
    // when the twenty and twenty-four clones went: the generator reads a spec
    // by group key and the validator reads the values back the same way, so a
    // disagreement anywhere between them shows up as an invalid draw.
    const int draws = 1000;

    test('$draws northern draws all validate', () {
      final Random rng = Random(4491);
      const YemenNorthernValidator validator = YemenNorthernValidator();
      for (final PlateSpec spec in _northernSpecs) {
        for (int i = 0; i < draws; i++) {
          final List<String?> values = YemenNorthernSerialGenerator.generate(spec, random: rng);
          expect(values.length, spec.slots.length, reason: spec.id);
          expect(values, isNot(contains(null)), reason: spec.id);
          final PlateValidation v = validator.validate(PlateEntry(spec: spec, values: values));
          expect(v.isValid, isTrue, reason: '${spec.id} $values: ${v.reason}');
        }
      }
    });

    test('$draws unified draws all validate', () {
      final Random rng = Random(4492);
      const YemenUnifiedValidator validator = YemenUnifiedValidator();
      for (final PlateSpec spec in _unifiedSpecs) {
        for (int i = 0; i < draws; i++) {
          final List<String?> values = YemenUnifiedSerialGenerator.generate(spec, random: rng);
          expect(values.length, spec.slots.length, reason: spec.id);
          expect(values, isNot(contains(null)), reason: spec.id);
          final PlateValidation v = validator.validate(PlateEntry(spec: spec, values: values));
          expect(v.isValid, isTrue, reason: '${spec.id} $values: ${v.reason}');
        }
      }
    });
  });

  group('the usage axis is a country block, not a spec', () {
    test('every issued northern usage resolves to a block', () {
      for (final YemenUsage usage in YemenUsage.northern) {
        expect(YemenCountry.northernFor(usage), isNotNull, reason: usage.name);
      }
    });

    test('every issued unified usage resolves to its own caption lines', () {
      final Set<List<String>> captions = <List<String>>{};
      for (final YemenUsage usage in YemenUsage.unified) {
        final PlateCountry country = YemenCountry.unifiedFor(usage);
        expect(country.captionLines, isNotEmpty, reason: usage.name);
        expect(country.captionLines.first, usage.unifiedArabic);
        captions.add(country.captionLines);
      }
      expect(captions.length, YemenUsage.unified.length);
    });

    test('a spec defaults to private, so an un-overridden canvas is sane', () {
      for (final PlateSpec spec in _unifiedSpecs) {
        expect(spec.country, same(YemenCountry.unifiedPrivate), reason: spec.id);
      }
      for (final PlateSpec spec in _northernSpecs) {
        expect(spec.country, same(YemenCountry.northernPrivate), reason: spec.id);
      }
    });
  });
}
