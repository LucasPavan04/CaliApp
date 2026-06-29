class DetalleRutinaModel {
  final String nombre;
  final int series;
  final int repeticiones;
  final double pesoSugerido;
  final String videoUrl;
  double? pesoLogrado;
  bool completado;

  DetalleRutinaModel({
    required this.nombre,
    required this.series,
    required this.repeticiones,
    required this.pesoSugerido,
    required this.videoUrl,
    this.pesoLogrado,
    this.completado = false,
  });

  DetalleRutinaModel copy() {
    return DetalleRutinaModel(
      nombre: nombre,
      series: series,
      repeticiones: repeticiones,
      pesoSugerido: pesoSugerido,
      videoUrl: videoUrl,
      pesoLogrado: pesoLogrado,
      completado: completado,
    );
  }
}
