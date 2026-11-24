enum FontSizeModel {
  small('Small', 0.9),
  medium('Medium', 1.0),
  large('Large', 1.15);

  const FontSizeModel(this.label, this.scale);

  final String label;
  final double scale;
}
