/// The 2009-series liveries with a reference photograph. The traffic police
/// list eight groups; the rest are either the older yellow series or a
/// separate two-row design.
// TODO(sudan-usages): add the other groups with a reference image each.
enum SudanUsage {
  /// Black on white.
  private('Private'),

  /// White on teal: buses and taxis.
  transport('Bus and taxi'),

  /// White on black.
  commercial('Commercial');

  const SudanUsage(this.english);

  final String english;
}
