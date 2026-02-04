class EjercicioModel {
  final String nombre;
  final String videoUrl;
  double? pesoLogrado;

  EjercicioModel({
    required this.nombre,
    required this.videoUrl,
    this.pesoLogrado,
  });
}