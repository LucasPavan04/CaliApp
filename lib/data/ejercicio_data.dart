import '../ui/models/ejercicio_model.dart';

class EjercicioData {
  // Singleton
  static final EjercicioData _instance = EjercicioData._internal();
  factory EjercicioData() => _instance;
  EjercicioData._internal();

  final List<EjercicioModel> ejercicios = [
    EjercicioModel(
      nombre: 'Press de banca',
      videoUrl: 'https://www.youtube.com/watch?v=SCVCLChPQFY',
    ),
    EjercicioModel(
      nombre: 'Sentadillas',
      videoUrl: 'https://www.youtube.com/watch?v=1oed-UmAxFs',
    ),
    EjercicioModel(
      nombre: 'Flexiones',
      videoUrl: 'https://www.youtube.com/watch?v=1oed-UmAxFs',
    ),
    EjercicioModel(
      nombre: 'Plancha',
      videoUrl: 'https://www.youtube.com/watch?v=1oed-UmAxFs',
    ),
    EjercicioModel(
      nombre: 'Dominadas',
      videoUrl: 'https://www.youtube.com/watch?v=1oed-UmAxFs',
    ),
    EjercicioModel(
      nombre: 'Curl bíceps',
      videoUrl: 'https://www.youtube.com/watch?v=1oed-UmAxFs',
    ),
  ];

  /// Actualiza un ejercicio por índice
  void actualizarEjercicio(int index, EjercicioModel ejercicio) {
    if (index >= 0 && index < ejercicios.length) {
      ejercicios[index] = ejercicio;
    }
  }
}
