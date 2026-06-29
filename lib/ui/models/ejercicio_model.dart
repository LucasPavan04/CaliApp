class EjercicioModel {
  final String nombre;
  final String videoUrl;
  final String descripcion;
  double? pesoLogrado;

  EjercicioModel({
    required this.nombre,
    required this.videoUrl,
    required this.descripcion,
    this.pesoLogrado,
  });
}