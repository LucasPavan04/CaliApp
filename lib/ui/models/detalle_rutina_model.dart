class DetalleRutinaModel {
  final String nombre;
  final int series;
  final int repeticiones;
  final double pesoSugerido;
  final String videoUrl;
  double? pesoLogrado;

  DetalleRutinaModel({
    required this.nombre,
    required this.series,
    required this.repeticiones,
    required this.pesoSugerido,
    required this.videoUrl,
    this.pesoLogrado,
  });
}
