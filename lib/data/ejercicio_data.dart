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
      descripcion:
          'Ejercicio compuesto para pecho, hombros y tríceps. Acostate en el banco, agarrá la barra con las manos un poco más anchas que los hombros y bajala controladamente hasta el pecho, luego empujala hacia arriba.',
    ),
    EjercicioModel(
      nombre: 'Sentadillas',
      videoUrl: 'https://www.youtube.com/watch?v=1oed-UmAxFs',
      descripcion:
          'Ejercicio fundamental para piernas y glúteos. Con la barra sobre los hombros, bajá flexionando rodillas y cadera como si te sentaras en una silla, manteniendo la espalda recta. Volvé a la posición inicial empujando con los talones.',
    ),
    EjercicioModel(
      nombre: 'Flexiones',
      videoUrl: 'https://www.youtube.com/watch?v=1oed-UmAxFs',
      descripcion:
          'Ejercicio de peso corporal para pecho, hombros y tríceps. Apoyá las manos en el suelo a la altura de los hombros, mantené el cuerpo alineado y bajá el pecho hasta casi tocar el suelo, luego empujá hacia arriba.',
    ),
    EjercicioModel(
      nombre: 'Plancha',
      videoUrl: 'https://www.youtube.com/watch?v=1oed-UmAxFs',
      descripcion:
          'Ejercicio isométrico para el core. Apoyá los antebrazos y las puntas de los pies en el suelo, manteniendo el cuerpo recto como una tabla. Contraé el abdomen y aguantá la posición el tiempo indicado.',
    ),
    EjercicioModel(
      nombre: 'Dominadas',
      videoUrl: 'https://www.youtube.com/watch?v=1oed-UmAxFs',
      descripcion:
          'Ejercicio de tracción para espalda y bíceps. Colgá de una barra con las palmas hacia afuera, subí el cuerpo hasta que la barbilla supere la barra y bajá de forma controlada.',
    ),
    EjercicioModel(
      nombre: 'Curl bíceps',
      videoUrl: 'https://www.youtube.com/watch?v=1oed-UmAxFs',
      descripcion:
          'Ejercicio de aislamiento para bíceps. De pie o sentado, sostené una mancuerna o barra con los brazos extendidos y flexioná los codos llevando el peso hacia los hombros, sin mover el cuerpo.',
    ),
  ];

  EjercicioModel? getPorNombre(String nombre) {
    try {
      return ejercicios.firstWhere((e) => e.nombre == nombre);
    } catch (_) {
      return null;
    }
  }

  /// Actualiza un ejercicio por índice
  void actualizarEjercicio(int index, EjercicioModel ejercicio) {
    if (index >= 0 && index < ejercicios.length) {
      ejercicios[index] = ejercicio;
    }
  }
}
