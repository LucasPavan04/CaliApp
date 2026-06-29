import 'package:cali_app/data/ejercicio_data.dart';
import 'package:cali_app/data/rutina_data.dart';
import 'package:cali_app/ui/models/detalle_rutina_model.dart';
import 'package:cali_app/ui/models/dia_rutina_model.dart';
import 'package:cali_app/ui/models/rutina_model.dart';
import 'package:cali_app/widgets/app_layout.dart';
import 'package:flutter/material.dart';

class AltaRutinaScreen extends StatefulWidget {
  final RutinaModel? rutinaExistente;

  const AltaRutinaScreen({super.key, this.rutinaExistente});

  @override
  State<AltaRutinaScreen> createState() => _AltaRutinaScreenState();
}

class _AltaRutinaScreenState extends State<AltaRutinaScreen> {
  static const _maxDias = 7;

  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final List<TextEditingController> _controllersToDispose = [];

  /// Días activos: clave = número de día (1-7)
  late Map<int, _DiaFormState> _dias;

  int? _diaExpandido;

  @override
  void initState() {
    super.initState();
    _dias = {};
    final rutina = widget.rutinaExistente;

    if (rutina != null) {
      _tituloController.text = rutina.nombre;
      _descripcionController.text = rutina.descripcion;
      for (final dia in rutina.dias) {
        _dias[dia.numero] = _DiaFormState.fromDia(dia, _controllersToDispose);
      }
      if (_dias.isNotEmpty) {
        _diaExpandido = _dias.keys.first;
      }
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    for (final dia in _dias.values) {
      dia.disposeControllers();
    }
    super.dispose();
  }

  void _toggleDia(int numero) {
    setState(() {
      if (_dias.containsKey(numero)) {
        _dias[numero]!.disposeControllers();
        _dias.remove(numero);
        if (_diaExpandido == numero) {
          _diaExpandido = _dias.keys.isNotEmpty ? _dias.keys.first : null;
        }
      } else {
        _dias[numero] = _DiaFormState.empty(numero, _controllersToDispose);
        _diaExpandido = numero;
      }
    });
  }

  void _guardarRutina() {
    final titulo = _tituloController.text.trim();
    final descripcion = _descripcionController.text.trim();

    if (titulo.isEmpty) {
      _mostrarError('Ingresá el título de la rutina');
      return;
    }

    if (_dias.isEmpty) {
      _mostrarError('Seleccioná al menos un día');
      return;
    }

    final diasOrdenados = _dias.keys.toList()..sort();
    final diasRutina = <DiaRutinaModel>[];

    for (final numero in diasOrdenados) {
      final dia = _dias[numero]!;
      final nombreDia = dia.nombreController.text.trim();
      if (nombreDia.isEmpty) {
        _mostrarError('Ingresá el nombre del Día $numero');
        return;
      }

      final seleccionados =
          dia.ejercicios.where((e) => e['seleccionado'] == true).toList();
      if (seleccionados.isEmpty) {
        _mostrarError('Agregá al menos un ejercicio al Día $numero');
        return;
      }

      for (final ejercicio in seleccionados) {
        final series = _textoEjercicio(ejercicio, 'series');
        final repeticiones = _textoEjercicio(ejercicio, 'repeticiones');
        final peso = _textoEjercicio(ejercicio, 'peso');

        if (series.trim().isEmpty ||
            repeticiones.trim().isEmpty ||
            peso.trim().isEmpty) {
          _mostrarError(
            'Completá series, repeticiones y peso para ${ejercicio['nombre']} (Día $numero)',
          );
          return;
        }

        if (int.tryParse(series) == null ||
            int.tryParse(repeticiones) == null ||
            double.tryParse(peso) == null) {
          _mostrarError('Datos inválidos en ${ejercicio['nombre']} (Día $numero)');
          return;
        }
      }

      diasRutina.add(DiaRutinaModel(
        numero: numero,
        nombre: nombreDia,
        ejercicios: seleccionados.map((e) {
          return DetalleRutinaModel(
            nombre: e['nombre'] as String,
            series: int.parse(_textoEjercicio(e, 'series')),
            repeticiones: int.parse(_textoEjercicio(e, 'repeticiones')),
            pesoSugerido: double.parse(_textoEjercicio(e, 'peso')),
            videoUrl: e['videoUrl'] as String,
          );
        }).toList(),
      ));
    }

    final id = widget.rutinaExistente?.id ??
        DateTime.now().millisecondsSinceEpoch.toString();
    final rutina = RutinaModel(
      id: id,
      nombre: titulo,
      descripcion: descripcion.isEmpty ? 'Rutina personalizada' : descripcion,
      dias: diasRutina,
    );

    if (widget.rutinaExistente != null) {
      RutinaData().actualizarPlantilla(rutina);
    } else {
      RutinaData().agregarPlantilla(rutina);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.rutinaExistente != null
                ? 'Rutina actualizada'
                : 'Rutina guardada correctamente',
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: const Color(0xffFFD700),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  String _textoEjercicio(Map<String, dynamic> ejercicio, String campo) {
    final controller =
        ejercicio['${campo}Controller'] as TextEditingController?;
    return controller?.text ?? ejercicio[campo].toString();
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje, style: const TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xffFFD700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final diasOrdenados = _dias.keys.toList()..sort();

    return AppLayout(
      showBackButton: true,
      content: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.rutinaExistente != null ? 'Editar rutina' : 'Nueva rutina',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _tituloController,
              decoration: InputDecoration(
                labelText: 'Título de la rutina',
                hintText: 'Ej: Rutina Full Body',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xffFFD700), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descripcionController,
              decoration: InputDecoration(
                labelText: 'Descripción (opcional)',
                hintText: 'Ej: 3 días por semana',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xffFFD700), width: 2),
                ),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            const Text(
              'Días de la rutina',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Seleccioná los días que va a tener la rutina',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_maxDias, (i) {
                final numero = i + 1;
                final activo = _dias.containsKey(numero);
                return FilterChip(
                  label: Text('Día $numero'),
                  selected: activo,
                  selectedColor: const Color(0xffFFD700).withOpacity(0.4),
                  checkmarkColor: Colors.black87,
                  onSelected: (_) => _toggleDia(numero),
                );
              }),
            ),
            if (_dias.isEmpty) ...[
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Seleccioná al menos un día para agregar ejercicios',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                ),
              ),
            ],
            ...diasOrdenados.map((numero) {
              final dia = _dias[numero]!;
              final expandido = _diaExpandido == numero;
              return _DiaCard(
                numero: numero,
                dia: dia,
                expandido: expandido,
                onToggle: () => setState(() {
                  _diaExpandido = expandido ? null : numero;
                }),
                onChanged: () => setState(() {}),
              );
            }),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _guardarRutina,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffFFD700),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  widget.rutinaExistente != null
                      ? 'Guardar cambios'
                      : 'Guardar rutina',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiaFormState {
  final TextEditingController nombreController;
  final List<Map<String, dynamic>> ejercicios;

  _DiaFormState({
    required this.nombreController,
    required this.ejercicios,
  });

  factory _DiaFormState.empty(int numero, List<TextEditingController> dispose) {
    final nombreController = TextEditingController(text: 'Día $numero');
    dispose.add(nombreController);
    return _DiaFormState(
      nombreController: nombreController,
      ejercicios: _buildEjercicios(null, dispose),
    );
  }

  factory _DiaFormState.fromDia(
    DiaRutinaModel dia,
    List<TextEditingController> dispose,
  ) {
    final nombreController = TextEditingController(text: dia.nombre);
    dispose.add(nombreController);
    return _DiaFormState(
      nombreController: nombreController,
      ejercicios: _buildEjercicios(dia, dispose),
    );
  }

  static List<Map<String, dynamic>> _buildEjercicios(
    DiaRutinaModel? dia,
    List<TextEditingController> dispose,
  ) {
    return EjercicioData().ejercicios.asMap().entries.map((e) {
      final ex = e.value;
      final coinciden =
          dia?.ejercicios.where((d) => d.nombre == ex.nombre).toList() ?? [];
      final detalle = coinciden.isNotEmpty ? coinciden.first : null;
      final seleccionado = detalle != null;
      final map = <String, dynamic>{
        'id': e.key,
        'nombre': ex.nombre,
        'videoUrl': ex.videoUrl,
        'seleccionado': seleccionado,
        'series': seleccionado ? detalle.series.toString() : '',
        'repeticiones': seleccionado ? detalle.repeticiones.toString() : '',
        'peso': seleccionado ? detalle.pesoSugerido.toString() : '',
      };
      if (seleccionado) {
        final sc = TextEditingController(text: map['series'].toString());
        final rc =
            TextEditingController(text: map['repeticiones'].toString());
        final pc = TextEditingController(text: map['peso'].toString());
        map['seriesController'] = sc;
        map['repeticionesController'] = rc;
        map['pesoController'] = pc;
        dispose.addAll([sc, rc, pc]);
      }
      return map;
    }).toList();
  }

  void disposeControllers() {
    nombreController.dispose();
    for (final e in ejercicios) {
      (e['seriesController'] as TextEditingController?)?.dispose();
      (e['repeticionesController'] as TextEditingController?)?.dispose();
      (e['pesoController'] as TextEditingController?)?.dispose();
    }
  }
}

class _DiaCard extends StatelessWidget {
  final int numero;
  final _DiaFormState dia;
  final bool expandido;
  final VoidCallback onToggle;
  final VoidCallback onChanged;

  const _DiaCard({
    required this.numero,
    required this.dia,
    required this.expandido,
    required this.onToggle,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cantEjercicios =
        dia.ejercicios.where((e) => e['seleccionado'] == true).length;

    return Card(
      margin: const EdgeInsets.only(top: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffFFD700).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Día $numero',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      cantEjercicios == 0
                          ? 'Sin ejercicios'
                          : '$cantEjercicios ejercicio${cantEjercicios == 1 ? '' : 's'}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Icon(
                    expandido ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),
          if (expandido) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: dia.nombreController,
                    decoration: InputDecoration(
                      labelText: 'Nombre del día',
                      hintText: 'Ej: Día $numero - Brazos',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xffFFD700),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Ejercicios',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...dia.ejercicios.map((ejercicio) {
                    return _EjercicioTile(
                      ejercicio: ejercicio,
                      onChanged: onChanged,
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EjercicioTile extends StatelessWidget {
  final Map<String, dynamic> ejercicio;
  final VoidCallback onChanged;

  const _EjercicioTile({
    required this.ejercicio,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final seleccionado = ejercicio['seleccionado'] as bool;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 0,
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                ejercicio['nombre'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              value: seleccionado,
              activeColor: const Color(0xffFFD700),
              onChanged: (val) {
                if (val == true) {
                  final sc = TextEditingController(
                    text: ejercicio['series'].toString(),
                  );
                  final rc = TextEditingController(
                    text: ejercicio['repeticiones'].toString(),
                  );
                  final pc = TextEditingController(
                    text: ejercicio['peso'].toString(),
                  );
                  ejercicio['seriesController'] = sc;
                  ejercicio['repeticionesController'] = rc;
                  ejercicio['pesoController'] = pc;
                } else {
                  (ejercicio['seriesController'] as TextEditingController?)
                      ?.dispose();
                  (ejercicio['repeticionesController'] as TextEditingController?)
                      ?.dispose();
                  (ejercicio['pesoController'] as TextEditingController?)
                      ?.dispose();
                  ejercicio.remove('seriesController');
                  ejercicio.remove('repeticionesController');
                  ejercicio.remove('pesoController');
                }
                ejercicio['seleccionado'] = val;
                onChanged();
              },
            ),
            if (seleccionado) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: ejercicio['seriesController']
                          as TextEditingController?,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Series',
                        border: OutlineInputBorder(),
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (value) => ejercicio['series'] = value,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: ejercicio['repeticionesController']
                          as TextEditingController?,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Reps',
                        border: OutlineInputBorder(),
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (value) => ejercicio['repeticiones'] = value,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: ejercicio['pesoController']
                          as TextEditingController?,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Peso (kg)',
                        border: OutlineInputBorder(),
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (value) => ejercicio['peso'] = value,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
