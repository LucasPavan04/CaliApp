import 'package:cali_app/ui/models/ejercicio_model.dart';
import 'package:cali_app/widgets/youtube_video_tile.dart';
import 'package:flutter/material.dart';

class EjercicioCard extends StatelessWidget {
  final EjercicioModel ejercicio;
  final VoidCallback? onEdit;

  const EjercicioCard({super.key, required this.ejercicio, this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      ejercicio.nombre,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if (onEdit != null)
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.grey.shade700),
                      onPressed: onEdit,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              YoutubeVideoTile(
                videoUrl: ejercicio.videoUrl,
                borderRadius: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
