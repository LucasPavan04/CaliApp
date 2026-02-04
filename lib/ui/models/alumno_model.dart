class Alumno {
  final String nombreCompleto;
  final String dni;
  final String direccion;
  final DateTime fechaNacimiento;
  final bool isAdmin;

  Alumno({
    required this.nombreCompleto,
    required this.dni,
    required this.direccion,
    required this.fechaNacimiento,
    this.isAdmin = false,
  });
}