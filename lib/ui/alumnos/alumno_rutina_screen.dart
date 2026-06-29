import 'package:cali_app/config/app_branding.dart';
import 'package:cali_app/data/rutina_data.dart';
import 'package:cali_app/ui/models/alumno_model.dart';
import 'package:cali_app/ui/models/rutina_model.dart';
import 'package:cali_app/widgets/app_layout.dart';
import 'package:cali_app/widgets/rutina_card.dart';
import 'package:flutter/material.dart';

class AlumnoRutinaScreen extends StatefulWidget {
  final Alumno alumno;
  /// Si true (admin viendo un alumno), muestra asignar y eliminar rutinas.
  final bool showAssignDelete;

  const AlumnoRutinaScreen({
    super.key,
    required this.alumno,
    this.showAssignDelete = false,
  });

  @override
  State<AlumnoRutinaScreen> createState() => _AlumnoRutinaScreenState();
}

class _AlumnoRutinaScreenState extends State<AlumnoRutinaScreen> {
  void _refrescar() => setState(() {});

  void _asignarRutina() async {
    final plantillas = RutinaData().getRutinasPlantilla();
    if (plantillas.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay plantillas. Creá una desde Rutinas.'),
            backgroundColor: AppBranding.primary,
          ),
        );
      }
      return;
    }
    if (!mounted) return;
    final elegida = await showModalBottomSheet<RutinaModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Elegir rutina para asignar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: plantillas.length,
                itemBuilder: (context, index) {
                  final r = plantillas[index];
                  return ListTile(
                    leading: const Icon(Icons.fitness_center, color: AppBranding.primary),
                    title: Text(
                      r.nombre,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${r.descripcion} · ${r.cantidadDias} día${r.cantidadDias == 1 ? '' : 's'}',
                    ),
                    onTap: () => Navigator.pop(context, r),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
    if (elegida != null) {
      RutinaData().asignarPlantillaAAlumno(widget.alumno.dni, elegida);
      _refrescar();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rutina "${elegida.nombre}" asignada'),
            backgroundColor: AppBranding.primary,
          ),
        );
      }
    }
  }

  void _confirmarEliminar(RutinaModel rutina) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quitar rutina'),
        content: Text(
          '¿Quitar la rutina "${rutina.nombre}" de ${widget.alumno.nombreCompleto}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Quitar'),
          ),
        ],
      ),
    );
    if (ok == true) {
      RutinaData().eliminarRutinaDeAlumno(widget.alumno.dni, rutina.id);
      _refrescar();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rutina quitada'),
            backgroundColor: AppBranding.primary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rutinas = RutinaData().getRutinas(widget.alumno.dni);

    return AppLayout(
      showBackButton: true,
      showFloatingActionButton: widget.showAssignDelete,
      icono: Icons.add,
      heroTag: 'FAB_ALUMNO_RUTINA',
      onPress: widget.showAssignDelete ? _asignarRutina : null,
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Rutinas de ${widget.alumno.nombreCompleto}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            if (widget.showAssignDelete && rutinas.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Tocá una rutina para ver el detalle. Usá el ícono de papelera para quitarla.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ...rutinas.map(
              (rutina) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: RutinaCardWidget(
                  rutina: rutina,
                  dniAlumno:
                      widget.showAssignDelete ? null : widget.alumno.dni,
                  onDelete: widget.showAssignDelete
                      ? () => _confirmarEliminar(rutina)
                      : null,
                ),
              ),
            ),
            if (rutinas.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.fitness_center,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No hay rutinas asignadas',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                      if (widget.showAssignDelete) ...[
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _asignarRutina,
                          icon: const Icon(Icons.add),
                          label: const Text('Asignar rutina'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppBranding.primary,
                            foregroundColor: Colors.black,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
