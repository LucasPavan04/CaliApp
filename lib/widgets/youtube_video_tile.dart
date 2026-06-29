import 'package:cali_app/config/app_branding.dart';
import 'package:cali_app/utils/youtube_utils.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Muestra la miniatura del video y un botón para reproducirlo.
/// El video se abre en la app de YouTube o en el navegador (evita errores 152/153 del embed en WebView).
class YoutubeVideoTile extends StatelessWidget {
  final String videoUrl;
  final double borderRadius;

  const YoutubeVideoTile({
    super.key,
    required this.videoUrl,
    this.borderRadius = 12,
  });

  Future<void> _reproducir(BuildContext context) async {
    final uri = Uri.tryParse(videoUrl);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo abrir el video. Probá copiando: $videoUrl'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final videoId = extractYoutubeVideoId(videoUrl);
    final thumbnailUrl = videoId != null ? youtubeThumbnailUrl(videoId) : null;

    if (videoId == null || videoId.isEmpty) {
      return _placeholder();
    }

    final height = MediaQuery.of(context).size.width * 9 / 16;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => _reproducir(context),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.network(
                  thumbnailUrl!,
                  height: height,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholderHeight(height),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: AppBranding.primary,
            child: InkWell(
              onTap: () => _reproducir(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_circle_filled, color: Colors.black87, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      'Reproducir video',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: const Center(
        child: Icon(Icons.videocam_off, size: 48, color: Colors.grey),
      ),
    );
  }

  Widget _placeholderHeight(double height) {
    return Container(
      height: height,
      color: Colors.grey.shade300,
      child: const Center(
        child: Icon(Icons.videocam_off, size: 48, color: Colors.grey),
      ),
    );
  }
}
