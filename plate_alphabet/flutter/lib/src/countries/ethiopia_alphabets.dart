import 'package:plate_core/plate_core.dart';

/// The alphabets behind Ethiopian slots. The plates print Western digits and
/// Latin capitals (the region code, `AA`), beside Ge'ez syllables for the
/// region and series.
///
/// The article lists no Ge'ez set, so [geez] is the thirty-four consonant
/// families of the Ethiopic block in all seven orders (`ሀ ሁ ሂ ሃ ሄ ህ ሆ`) —
/// every syllable the references show, picked rather than typed because no
/// keyboard is assumed.
abstract final class EthiopiaAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;

  static const PlateAlphabet geez = PlateAlphabet.pattern(
    id: 'et.geez',
    include:
        'ሀ ሁ ሂ ሃ ሄ ህ ሆ ለ ሉ ሊ ላ ሌ ል ሎ ሐ ሑ ሒ ሓ ሔ ሕ ሖ መ ሙ ሚ ማ ሜ ም ሞ ሠ ሡ ሢ ሣ ሤ ሥ ሦ ረ ሩ ሪ ራ ሬ ር ሮ ሰ ሱ ሲ ሳ ሴ ስ ሶ ሸ ሹ ሺ ሻ ሼ ሽ ሾ ቀ ቁ ቂ ቃ ቄ ቅ ቆ በ ቡ ቢ ባ ቤ ብ ቦ ቨ ቩ ቪ ቫ ቬ ቭ ቮ ተ ቱ ቲ ታ ቴ ት ቶ ቸ ቹ ቺ ቻ ቼ ች ቾ ኀ ኁ ኂ ኃ ኄ ኅ ኆ ነ ኑ ኒ ና ኔ ን ኖ ኘ ኙ ኚ ኛ ኜ ኝ ኞ አ ኡ ኢ ኣ ኤ እ ኦ ከ ኩ ኪ ካ ኬ ክ ኮ ኸ ኹ ኺ ኻ ኼ ኽ ኾ ወ ዉ ዊ ዋ ዌ ው ዎ ዐ ዑ ዒ ዓ ዔ ዕ ዖ ዘ ዙ ዚ ዛ ዜ ዝ ዞ ዠ ዡ ዢ ዣ ዤ ዥ ዦ የ ዩ ዪ ያ ዬ ይ ዮ ደ ዱ ዲ ዳ ዴ ድ ዶ ጀ ጁ ጂ ጃ ጄ ጅ ጆ ገ ጉ ጊ ጋ ጌ ግ ጎ ጠ ጡ ጢ ጣ ጤ ጥ ጦ ጨ ጩ ጪ ጫ ጬ ጭ ጮ ጰ ጱ ጲ ጳ ጴ ጵ ጶ ጸ ጹ ጺ ጻ ጼ ጽ ጾ ፀ ፁ ፂ ፃ ፄ ፅ ፆ ፈ ፉ ፊ ፋ ፌ ፍ ፎ ፐ ፑ ፒ ፓ ፔ ፕ ፖ',
    input: AlphabetInput.chosen,
    isNumeric: false,
  );
}
