/// Governorates on modern West Bank plates (since July 2018): thirteen issued
/// letters, closed. `I` and `O` are skipped as digit look-alikes; `P`–`T` belong
/// to pre-2012 Gaza.
enum PSGovernorate {
  jenin('A', 'جنين', 'Jenin'),
  tulkarm('B', 'طولكرم', 'Tulkarm'),
  tubas('C', 'طوباس', 'Tubas'),
  nablus('D', 'نابلس', 'Nablus'),
  qalqilya('E', 'قلقيلية', 'Qalqilya'),
  salfit('F', 'سلفيت', 'Salfit'),
  jericho('G', 'أريحا', 'Jericho'),
  ramallah('H', 'رام الله', 'Ramallah'),

  /// `I` is skipped between [ramallah] and here.
  jerusalem('J', 'القدس', 'Jerusalem'),
  bethlehem('K', 'بيت لحم', 'Bethlehem'),
  hebron('L', 'الخليل', 'Hebron'),
  dura('M', 'دورا', 'Dura'),
  yatta('N', 'يطا', 'Yatta');

  const PSGovernorate(this.letter, this.arabicName, this.englishName);

  final String letter, arabicName, englishName;

  static const List<String> letters = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 'N', //
  ];

  /// Never issued; misread as `1`/`J` and `0`.
  static const List<String> confusableLetters = ['I', 'O'];

  /// Pre-2012 Gaza letters, rejected on West Bank plates.
  static const List<String> reservedGazaLetters = ['P', 'Q', 'R', 'S', 'T'];

  static PSGovernorate? byLetter(String letter) =>
      values.where((g) => g.letter == letter).firstOrNull;
}
