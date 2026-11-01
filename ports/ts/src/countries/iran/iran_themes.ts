import type { PlateTheme } from '../../core/theme/plate_theme';
import { IranThemes as themes } from './themes';

function themeForLetter(letter: string): PlateTheme {
  switch (letter) {
    case 'ت':
    case 'ع':
    case 'ک':
      return themes.blackOnYellow;
    case 'الف':
      return themes.whiteOnRed;
    case 'پ':
    case 'ث':
      return themes.whiteOnGreen;
    case 'ش':
      return themes.blackOnTan;
    case 'ز':
    case 'ف':
      return themes.whiteOnForcesBlue;
    case 'D':
    case 'S':
      return themes.blackOnCyan;
    default:
      return themes.blackOnWhite;
  }
}

export const IranThemes = {
  /** PlateSpec.resolveTheme for IranPlates.civil: the colours of the class the series letter belongs to, on base's rim and corner. */
  civil(base: PlateTheme, group: (key: string) => string): PlateTheme {
    const t = themeForLetter(group('letter'));
    return base.copyWith({
      plateBackground: t.plateBackground,
      plateBorder: t.plateBorder,
      ink: t.ink,
      dividerColor: t.dividerColor,
      activeColor: t.activeColor,
      inactiveColor: t.inactiveColor,
    });
  },
};
