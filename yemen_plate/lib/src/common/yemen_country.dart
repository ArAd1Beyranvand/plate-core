import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

import 'yemen_colors.dart';
import 'yemen_usage.dart';

/// Yemen's plate chrome. All share `code: 'ye'` and so compare equal; tell
/// plates apart by [PlateSpec.id].
abstract final class YemenCountry {
  // System A: the blue side panel carries the usage captions.

  /// The side panel without a caption; [unifiedFor] picks the captioned ones.
  static const PlateCountry unified = PlateCountry(
    code: 'ye',
    captionLines: <String>[],
    panelColor: YemenColors.unifiedSidePanel,
    panelTextColor: YemenColors.unifiedInk,
    flag: null,
  );

  static const PlateCountry unifiedPrivate = PlateCountry(
    code: 'ye',
    captionLines: <String>['خصوصي', 'PRIV.'],
    panelColor: YemenColors.unifiedSidePanel,
    panelTextColor: YemenColors.unifiedInk,
    flag: null,
  );

  static const PlateCountry unifiedForHire = PlateCountry(
    code: 'ye',
    captionLines: <String>['أجرة', 'TAXI'],
    panelColor: YemenColors.unifiedSidePanel,
    panelTextColor: YemenColors.unifiedInk,
    flag: null,
  );

  static const PlateCountry unifiedTransport = PlateCountry(
    code: 'ye',
    captionLines: <String>['نقل', 'TRANS.'],
    panelColor: YemenColors.unifiedSidePanel,
    panelTextColor: YemenColors.unifiedInk,
    flag: null,
  );

  static const PlateCountry unifiedGovernment = PlateCountry(
    code: 'ye',
    captionLines: <String>['حكومي', 'GOV.'],
    panelColor: YemenColors.unifiedSidePanel,
    panelTextColor: YemenColors.unifiedInk,
    flag: null,
  );

  static const PlateCountry unifiedPolice = PlateCountry(
    code: 'ye',
    captionLines: <String>['شرطة', 'POLICE'],
    panelColor: YemenColors.unifiedSidePanel,
    panelTextColor: YemenColors.unifiedInk,
    flag: null,
  );

  /// The unified panel captioned for [usage], or [unified] if System A does not
  /// issue it.
  static PlateCountry unifiedFor(YemenUsage usage) => switch (usage) {
    YemenUsage.private => unifiedPrivate,
    YemenUsage.forHire => unifiedForHire,
    YemenUsage.transport => unifiedTransport,
    YemenUsage.government => unifiedGovernment,
    YemenUsage.police => unifiedPolice,
    YemenUsage.military => unified,
  };

  // System B: a transparent panel carrying the usage word in ink.

  /// الیمن - خصوصي in black ink. The panel is transparent so a mismatched theme
  /// cannot show a coloured block.
  static const PlateCountry northernPrivate = PlateCountry(
    code: 'ye',
    captionLines: <String>['الیمن - خصوصي'],
    panelColor: _transparent,
    panelTextColor: YemenColors.darkInk,
    flag: null,
  );

  /// اجرة in black ink, spelled without the hamza of the unified plate.
  static const PlateCountry northernForHire = PlateCountry(
    code: 'ye',
    captionLines: <String>['اجرة'],
    panelColor: _transparent,
    panelTextColor: YemenColors.darkInk,
    flag: null,
  );

  static const PlateCountry northernTransport = PlateCountry(
    code: 'ye',
    captionLines: <String>['نقل'],
    panelColor: _transparent,
    panelTextColor: YemenColors.darkInk,
    flag: null,
  );

  /// White ink, no usage word (see [YemenUsage.government]).
  static const PlateCountry northernGovernment = PlateCountry(
    code: 'ye',
    captionLines: <String>[],
    panelColor: _transparent,
    panelTextColor: YemenColors.lightInk,
    flag: null,
  );

  /// White ink, no usage word.
  static const PlateCountry northernMilitaryClassic = PlateCountry(
    code: 'ye',
    captionLines: <String>[],
    panelColor: _transparent,
    panelTextColor: YemenColors.lightInk,
    flag: null,
  );

  /// Red ink, no usage word; told from [northernMilitaryClassic] by the theme.
  static const PlateCountry northernMilitaryModern = PlateCountry(
    code: 'ye',
    captionLines: <String>[],
    panelColor: _transparent,
    panelTextColor: YemenColors.militaryRed,
    flag: null,
  );

  /// The northern block for [usage]; police takes [northernGovernment].
  static PlateCountry northernFor(YemenUsage usage) => switch (usage) {
    YemenUsage.private => northernPrivate,
    YemenUsage.forHire => northernForHire,
    YemenUsage.transport => northernTransport,
    YemenUsage.government || YemenUsage.police => northernGovernment,
    YemenUsage.military => northernMilitaryClassic,
  };

  // Southern governorates: the usage colour is the strip (and Marib's top band),
  // painted as `PlateFill.panel`, so it rides on the country block.

  /// Private: blue strip.
  static const PlateCountry southernPrivate = PlateCountry(
    code: 'ye',
    captionLines: <String>[],
    panelColor: YemenColors.southernBlue,
    panelTextColor: YemenColors.southernInk,
  );

  /// Taxis and buses: yellow strip. Also Marib's motorcycle band.
  static const PlateCountry southernForHire = PlateCountry(
    code: 'ye',
    captionLines: <String>[],
    panelColor: YemenColors.southernYellow,
    panelTextColor: YemenColors.southernInk,
  );

  /// Trucks and vans: red strip.
  static const PlateCountry southernCommercial = PlateCountry(
    code: 'ye',
    captionLines: <String>[],
    panelColor: YemenColors.southernRed,
    panelTextColor: YemenColors.southernInk,
  );

  /// Government: green strip.
  static const PlateCountry southernGovernment = PlateCountry(
    code: 'ye',
    captionLines: <String>[],
    panelColor: YemenColors.southernGreen,
    panelTextColor: YemenColors.southernInk,
  );

  /// Temporary and police share the private blue (the مؤقت strip, the الشرطة band).
  static const PlateCountry southernTemporary = southernPrivate;
  static const PlateCountry southernPolice = southernPrivate;

  /// The southern strip for [usage]; military is not issued there and falls back
  /// to private.
  static PlateCountry southernFor(YemenUsage usage) => switch (usage) {
    YemenUsage.private => southernPrivate,
    YemenUsage.forHire => southernForHire,
    YemenUsage.transport => southernCommercial,
    YemenUsage.government => southernGovernment,
    YemenUsage.police => southernPolice,
    YemenUsage.military => southernPrivate,
  };

  /// Aden and Taiz print no country block.
  static const PlateCountry plain = PlateCountry(
    code: 'ye',
    captionLines: <String>[],
    panelColor: _transparent,
    panelTextColor: YemenColors.southernInk,
  );

  static const Color _transparent = Color(0x00000000);
}
