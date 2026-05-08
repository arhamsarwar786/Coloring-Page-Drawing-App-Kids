enum DrawingBrushSize {
  thin(label: 'Thin', scale: 0.72),
  standard(label: 'Standard', scale: 1.0),
  thick(label: 'Thick', scale: 1.38);

  const DrawingBrushSize({
    required this.label,
    required this.scale,
  });

  final String label;
  final double scale;
}
