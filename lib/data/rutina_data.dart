import '../data/ejercicio_data.dart';
import '../ui/models/detalle_rutina_model.dart';
import '../ui/models/dia_rutina_model.dart';
import '../ui/models/ejercicio_model.dart';
import '../ui/models/rutina_model.dart';

class RutinaData {
  static final RutinaData _instance = RutinaData._internal();
  factory RutinaData() => _instance;
  RutinaData._internal() {
    asignarPlantillaAAlumno('87654321', _rutinasPorDefecto().first);
  }

  final Map<String, List<RutinaModel>> _rutinasPorDni = {};
  final List<RutinaModel> _plantillas = [];
  final Map<String, DateTime> _ultimoDiaExtraPorDni = {};

  /// Rutinas asignadas al alumno. Los alumnos nuevos tienen lista vacía.
  List<RutinaModel> getRutinas(String dni) {
    if (_rutinasPorDni.containsKey(dni)) {
      return List.from(_rutinasPorDni[dni]!);
    }
    return [];
  }

  void setRutinas(String dni, List<RutinaModel> rutinas) {
    _rutinasPorDni[dni] = rutinas;
  }

  void agregarRutina(String dni, RutinaModel rutina) {
    final lista = _rutinasPorDni[dni] ??= [];
    lista.add(rutina);
  }

  /// Plantillas: por defecto + las creadas por el admin
  List<RutinaModel> getRutinasPlantilla() {
    return [..._rutinasPorDefecto(), ..._plantillas];
  }

  /// Agrega una nueva plantilla creada desde AltaRutinaScreen
  void agregarPlantilla(RutinaModel rutina) {
    _plantillas.add(rutina);
  }

  /// Devuelve la plantilla con ese id (solo las creadas por el admin, no las por defecto)
  RutinaModel? getPlantillaPorId(String id) {
    try {
      return _plantillas.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Actualiza una plantilla existente (solo las creadas por el admin)
  void actualizarPlantilla(RutinaModel rutina) {
    final i = _plantillas.indexWhere((r) => r.id == rutina.id);
    if (i >= 0) _plantillas[i] = rutina;
  }

  /// Asigna una plantilla a un alumno (copia la rutina a sus rutinas)
  void asignarPlantillaAAlumno(String dni, RutinaModel plantilla) {
    agregarRutina(dni, plantilla.copy());
  }

  RutinaModel? getRutinaAlumno(String dni, String rutinaId) {
    final lista = _rutinasPorDni[dni];
    if (lista == null) return null;
    try {
      return lista.firstWhere((r) => r.id == rutinaId);
    } catch (_) {
      return null;
    }
  }

  void resetCompletadosDia(String dni, String rutinaId, int diaNumero) {
    final rutina = getRutinaAlumno(dni, rutinaId);
    if (rutina == null) return;
    for (final dia in rutina.dias) {
      if (dia.numero == diaNumero) {
        for (final ejercicio in dia.ejercicios) {
          ejercicio.completado = false;
        }
        break;
      }
    }
  }

  /// Quita una rutina de un alumno por id
  void eliminarRutinaDeAlumno(String dni, String rutinaId) {
    final lista = _rutinasPorDni[dni];
    if (lista == null) return;
    lista.removeWhere((r) => r.id == rutinaId);
  }

  bool puedeGenerarDiaExtra(String dni) {
    final ultimo = _ultimoDiaExtraPorDni[dni];
    if (ultimo == null) return true;
    return !_esMismaSemana(ultimo, DateTime.now());
  }

  /// Genera un día extra con ejercicios que no están en las rutinas del alumno.
  /// Devuelve null si ya usó el beneficio esta semana o no hay ejercicios disponibles.
  RutinaModel? generarDiaExtra(String dni) {
    if (!puedeGenerarDiaExtra(dni)) return null;

    final usados = _ejerciciosEnRutinasAlumno(dni);
    final disponibles = EjercicioData()
        .ejercicios
        .where((e) => !usados.contains(e.nombre))
        .toList();

    if (disponibles.isEmpty) return null;

    final rutina = RutinaModel(
      id: 'extra_${DateTime.now().millisecondsSinceEpoch}',
      nombre: 'Día extra',
      descripcion: 'Ejercicios complementarios',
      dias: [
        DiaRutinaModel(
          numero: 1,
          nombre: 'Día extra',
          ejercicios:
              disponibles.map(_detalleDesdeEjercicio).toList(),
        ),
      ],
    );

    agregarRutina(dni, rutina);
    _ultimoDiaExtraPorDni[dni] = DateTime.now();
    return rutina;
  }

  Set<String> _ejerciciosEnRutinasAlumno(String dni) {
    final nombres = <String>{};
    for (final rutina in _rutinasPorDni[dni] ?? []) {
      for (final dia in rutina.dias) {
        for (final ejercicio in dia.ejercicios) {
          nombres.add(ejercicio.nombre);
        }
      }
    }
    return nombres;
  }

  static bool _esMismaSemana(DateTime a, DateTime b) {
    final inicioA = DateTime(a.year, a.month, a.day)
        .subtract(Duration(days: a.weekday - DateTime.monday));
    final inicioB = DateTime(b.year, b.month, b.day)
        .subtract(Duration(days: b.weekday - DateTime.monday));
    return inicioA.year == inicioB.year &&
        inicioA.month == inicioB.month &&
        inicioA.day == inicioB.day;
  }

  static DetalleRutinaModel _detalleDesdeEjercicio(EjercicioModel ejercicio) {
    final (series, repeticiones, peso) = switch (ejercicio.nombre) {
      'Flexiones' => (3, 15, 0.0),
      'Dominadas' => (3, 8, 0.0),
      'Plancha' => (3, 30, 0.0),
      _ => (3, 12, 10.0),
    };
    return DetalleRutinaModel(
      nombre: ejercicio.nombre,
      series: series,
      repeticiones: repeticiones,
      pesoSugerido: peso,
      videoUrl: ejercicio.videoUrl,
    );
  }

  static List<RutinaModel> _rutinasPorDefecto() {
    return [
      RutinaModel(
        id: '1',
        nombre: 'Rutina Full Body',
        descripcion: '3 días por semana',
        dias: [
          DiaRutinaModel(
            numero: 1,
            nombre: 'Día 1 - Brazos',
            ejercicios: [
              DetalleRutinaModel(
                nombre: 'Press de banca',
                series: 4,
                repeticiones: 10,
                pesoSugerido: 60,
                videoUrl: 'https://www.youtube.com/watch?v=SCVCLChPQFY',
              ),
              DetalleRutinaModel(
                nombre: 'Curl bíceps',
                series: 3,
                repeticiones: 12,
                pesoSugerido: 10,
                videoUrl: 'https://www.youtube.com/watch?v=1oed-UmAxFs',
              ),
            ],
          ),
          DiaRutinaModel(
            numero: 2,
            nombre: 'Día 2 - Piernas',
            ejercicios: [
              DetalleRutinaModel(
                nombre: 'Sentadillas',
                series: 4,
                repeticiones: 12,
                pesoSugerido: 80,
                videoUrl: 'https://www.youtube.com/watch?v=1oed-UmAxFs',
              ),
            ],
          ),
          DiaRutinaModel(
            numero: 3,
            nombre: 'Día 3 - Abdomen',
            ejercicios: [
              DetalleRutinaModel(
                nombre: 'Plancha',
                series: 3,
                repeticiones: 30,
                pesoSugerido: 0,
                videoUrl: 'https://www.youtube.com/watch?v=1oed-UmAxFs',
              ),
            ],
          ),
        ],
      ),
    ];
  }
}
