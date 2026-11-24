enum FontModel {
  system(null),
  manrope('Manrope'),
  inter('Inter');

  const FontModel(this.family);

  final String? family;
}
