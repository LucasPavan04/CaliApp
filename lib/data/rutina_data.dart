import '../ui/models/detalle_rutina_model.dart';
import '../ui/models/rutina_model.dart';

class RutinaData {
  static final RutinaData _instance = RutinaData._internal();
  factory RutinaData() => _instance;
  RutinaData._internal();

  final Map<String, List<RutinaModel>> _rutinasPorDni = {};
  final List<RutinaModel> _plantillas = [];

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
    agregarRutina(dni, plantilla);
  }

  /// Quita una rutina de un alumno por id
  void eliminarRutinaDeAlumno(String dni, String rutinaId) {
    final lista = _rutinasPorDni[dni];
    if (lista == null) return;
    lista.removeWhere((r) => r.id == rutinaId);
  }

  static List<RutinaModel> _rutinasPorDefecto() {
    return [
      RutinaModel(
        id: '1',
        nombre: 'Día 1 - Brazos',
        descripcion: 'Volumen',
        detalles: [
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
      RutinaModel(
        id: '2',
        nombre: 'Día 2 - Piernas',
        descripcion: 'Fuerza',
        detalles: [
          DetalleRutinaModel(
            nombre: 'Sentadillas',
            series: 4,
            repeticiones: 12,
            pesoSugerido: 80,
            videoUrl: 'https://www.youtube.com/watch?v=1oed-UmAxFs',
          ),
        ],
      ),
      RutinaModel(
        id: '3',
        nombre: 'Día 3 - Abdomen',
        descripcion: 'Explosividad',
        detalles: [
          DetalleRutinaModel(
            nombre: 'Plancha',
            series: 3,
            repeticiones: 30,
            pesoSugerido: 0,
            videoUrl: 'https://www.youtube.com/watch?v=1oed-UmAxFs',
          ),
        ],
      ),
    ];
  }
}
