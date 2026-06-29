import 'package:cali_app/widgets/app_layout.dart';
import 'package:cali_app/widgets/youtube_video_tile.dart';
import 'package:flutter/material.dart';

class InfoEjercicioScreen extends StatelessWidget {
  final String nombre;
  final String videoUrl;
  final String descripcion;

  const InfoEjercicioScreen({
    super.key,
    required this.nombre,
    required this.videoUrl,
    required this.descripcion,
  });

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      showBackButton: true,
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nombre,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            YoutubeVideoTile(
              videoUrl: videoUrl,
              borderRadius: 12,
            ),
            const SizedBox(height: 24),
            const Text(
              '¿En qué consiste?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              descripcion,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
