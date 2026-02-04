import 'package:cali_app/data/rutina_data.dart';
import 'package:cali_app/ui/ejercicios/alta_rutina_screen.dart';
import 'package:cali_app/ui/models/detalle_rutina_model.dart';
import 'package:cali_app/ui/models/rutina_model.dart';
import 'package:cali_app/widgets/app_layout.dart';
import 'package:cali_app/widgets/youtube_video_tile.dart';
import 'package:flutter/material.dart';

class DetalleRutinaScreen extends StatefulWidget {
  final RutinaModel rutina;

  const DetalleRutinaScreen({super.key, required this.rutina});

  @override
  State<DetalleRutinaScreen> createState() => _DetalleRutinaScreenState();
}

class _DetalleRutinaScreenState extends State<DetalleRutinaScreen> {
  @override
  Widget build(BuildContext context) {
    final puedeEditar = RutinaData().getPlantillaPorId(widget.rutina.id) != null;

    return AppLayout(
      showBackButton: true,
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.rutina.nombre,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.rutina.descripcion,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (puedeEditar)
                    TextButton.icon(
                      onPressed: () async {
                        final actualizado = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AltaRutinaScreen(
                              rutinaExistente: widget.rutina,
                            ),
                          ),
                        );
                        if (actualizado == true && mounted) {
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Editar'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xffFFD700),
                      ),
                    ),
                ],
              ),
            ),
            ...widget.rutina.detalles.map((d) => _DetalleEjercicioTile(detalle: d)),
          ],
        ),
      ),
    );
  }
}

class _DetalleEjercicioTile extends StatefulWidget {
  final DetalleRutinaModel detalle;

  const _DetalleEjercicioTile({required this.detalle});

  @override
  State<_DetalleEjercicioTile> createState() => _DetalleEjercicioTileState();
}

class _DetalleEjercicioTileState extends State<_DetalleEjercicioTile> {
  @override
  Widget build(BuildContext context) {
    final d = widget.detalle;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                d.nombre,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _chip('${d.series} series', Icons.repeat),
                  const SizedBox(width: 8),
                  _chip('${d.repeticiones} reps', Icons.fitness_center),
                  const SizedBox(width: 8),
                  _chip('${d.pesoSugerido} kg', Icons.monitor_weight_outlined),
                ],
              ),
              const SizedBox(height: 12),
              YoutubeVideoTile(
                videoUrl: d.videoUrl,
                borderRadius: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xffFFD700).withOpacity(0.25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
