import 'package:cali_app/data/ejercicio_data.dart';
import 'package:cali_app/data/rutina_data.dart';
import 'package:cali_app/ui/models/detalle_rutina_model.dart';
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
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  /// Ejercicios cargados desde EjercicioData, con datos del formulario
  late List<Map<String, dynamic>> _ejercicios;
  final List<TextEditingController> _controllersToDispose = [];

  @override
  void initState() {
    super.initState();
    final lista = EjercicioData().ejercicios;
    final rutina = widget.rutinaExistente;

    _ejercicios = lista.asMap().entries.map((e) {
      final ex = e.value;
      final coinciden = rutina?.detalles.where((d) => d.nombre == ex.nombre).toList() ?? [];
      final detalle = coinciden.isNotEmpty ? coinciden.first : null;
      final seleccionado = detalle != null;
      return <String, dynamic>{
        'id': e.key,
        'nombre': ex.nombre,
        'videoUrl': ex.videoUrl,
        'seleccionado': seleccionado,
        'series': seleccionado ? detalle.series.toString() : '',
        'repeticiones': seleccionado ? detalle.repeticiones.toString() : '',
        'peso': seleccionado ? detalle.pesoSugerido.toString() : '',
      };
    }).toList();

    if (rutina != null) {
      _tituloController.text = rutina.nombre;
      _descripcionController.text = rutina.descripcion;
      for (final e in _ejercicios) {
        if (e['seleccionado'] == true) {
          final sc = TextEditingController(text: e['series'].toString());
          final rc = TextEditingController(text: e['repeticiones'].toString());
          final pc = TextEditingController(text: e['peso'].toString());
          e['seriesController'] = sc;
          e['repeticionesController'] = rc;
          e['pesoController'] = pc;
          _controllersToDispose.addAll([sc, rc, pc]);
        }
      }
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    for (final c in _controllersToDispose) {
      c.dispose();
    }
    super.dispose();
  }

  void _guardarRutina() {
    final titulo = _tituloController.text.trim();
    final descripcion = _descripcionController.text.trim();
    final ejerciciosSeleccionados =
        _ejercicios.where((e) => e['seleccionado'] == true).toList();

    if (titulo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ingresá el título de la rutina',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Color(0xffFFD700),
        ),
      );
      return;
    }

    if (ejerciciosSeleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccioná al menos un ejercicio'),
          backgroundColor: Color(0xffFFD700),
        ),
      );
      return;
    }

    for (var ejercicio in ejerciciosSeleccionados) {
      final series = (ejercicio['seriesController'] as TextEditingController?)?.text ?? ejercicio['series'].toString();
      final repeticiones = (ejercicio['repeticionesController'] as TextEditingController?)?.text ?? ejercicio['repeticiones'].toString();
      final peso = (ejercicio['pesoController'] as TextEditingController?)?.text ?? ejercicio['peso'].toString();

      if (series.trim().isEmpty || repeticiones.trim().isEmpty || peso.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Completá series, repeticiones y peso para ${ejercicio['nombre']}',
            ),
            backgroundColor: Colors.orange.shade700,
          ),
        );
        return;
      }

      if (int.tryParse(series) == null || int.tryParse(repeticiones) == null || double.tryParse(peso) == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Datos inválidos en ${ejercicio['nombre']}'),
            backgroundColor: Colors.orange.shade700,
          ),
        );
        return;
      }
    }

    final detalles = ejerciciosSeleccionados.map((e) {
      final series = (e['seriesController'] as TextEditingController?)?.text ?? e['series'].toString();
      final repeticiones = (e['repeticionesController'] as TextEditingController?)?.text ?? e['repeticiones'].toString();
      final peso = (e['pesoController'] as TextEditingController?)?.text ?? e['peso'].toString();
      return DetalleRutinaModel(
        nombre: e['nombre'] as String,
        series: int.parse(series),
        repeticiones: int.parse(repeticiones),
        pesoSugerido: double.parse(peso),
        videoUrl: e['videoUrl'] as String,
      );
    }).toList();

    final id = widget.rutinaExistente?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final rutina = RutinaModel(
      id: id,
      nombre: titulo,
      descripcion: descripcion.isEmpty ? 'Rutina personalizada' : descripcion,
      detalles: detalles,
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
            widget.rutinaExistente != null ? 'Rutina actualizada' : 'Rutina guardada correctamente',
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: const Color(0xffFFD700),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                hintText: 'Ej: Día 1 - Brazos',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xffFFD700), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descripcionController,
              decoration: InputDecoration(
                labelText: 'Descripción (opcional)',
                hintText: 'Ej: Volumen / Fuerza',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xffFFD700), width: 2),
                ),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            const Text(
              'Ejercicios disponibles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            ..._ejercicios.map((ejercicio) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CheckboxListTile(
                        title: Text(
                          ejercicio['nombre'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        value: ejercicio['seleccionado'] as bool,
                        activeColor: const Color(0xffFFD700),
                        onChanged: (val) {
                          setState(() {
                            ejercicio['seleccionado'] = val;
                          });
                        },
                      ),
                      if (ejercicio['seleccionado'] as bool) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: ejercicio['seriesController'] as TextEditingController?,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Series',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                onChanged: (value) => ejercicio['series'] = value,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: ejercicio['repeticionesController'] as TextEditingController?,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Repeticiones',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                onChanged: (value) => ejercicio['repeticiones'] = value,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: ejercicio['pesoController'] as TextEditingController?,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Peso (kg)',
                                  border: OutlineInputBorder(),
                                  isDense: true,
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
            }).toList(),
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
                child: Text(widget.rutinaExistente != null ? 'Guardar cambios' : 'Guardar rutina'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
