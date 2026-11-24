enum FontModel {
  system(null, 'System'),
  manrope('Manrope', 'Manrope'),
  inter('Inter', 'Inter');

  const FontModel(this.family, this.label);

  final String? family;
  final String label;
}
