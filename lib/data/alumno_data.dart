 import '../ui/models/alumno_model.dart';

class AlumnoData {
  static final AlumnoData _instance = AlumnoData._internal();
  factory AlumnoData() => _instance;
  AlumnoData._internal();

  final List<Alumno> alumnos = [
    Alumno(
      nombreCompleto: 'Juan Pérez',
      dni: '12345678',
      direccion: 'Av. Siempre Viva 742',
      fechaNacimiento: DateTime(1990, 5, 15),
      isAdmin: true,
    ),
    Alumno(
      nombreCompleto: 'María García',
      dni: '87654321',
      direccion: 'Av. Siempre Viva 742',
      fechaNacimiento: DateTime(1992, 8, 20),
    ),
    Alumno(
      nombreCompleto: 'Lucas Fernández',
      dni: '45678912',
      direccion: 'Av. Siempre Viva 742',
      fechaNacimiento: DateTime(1988, 3, 10),
    ),
    Alumno(
      nombreCompleto: 'Ana Torres',
      dni: '19876543',
      direccion: 'Av. Siempre Viva 742',
      fechaNacimiento: DateTime(1995, 11, 5),
    ),
  ];

  Alumno? findByDni(String dni) {
    try {
      return alumnos.firstWhere((a) => a.dni == dni.trim());
    } catch (_) {
      return null;
    }
  }

  /// Actualiza un alumno existente (busca por DNI anterior)
  void actualizarAlumno(String dniAnterior, Alumno nuevo) {
    final i = alumnos.indexWhere((a) => a.dni == dniAnterior);
    if (i >= 0) alumnos[i] = nuevo;
  }
}
