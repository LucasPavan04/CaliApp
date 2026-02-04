/// Extrae el ID del video de una URL de YouTube.
/// Soporta: watch?v=ID, youtu.be/ID, youtube.com/shorts/ID
String? extractYoutubeVideoId(String url) {
  if (url.isEmpty) return null;
  final uri = Uri.tryParse(url);
  if (uri == null) return null;

  // youtu.be/VIDEO_ID
  if (uri.host.contains('youtu.be')) {
    final id = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    return id?.split('?').first;
  }

  // youtube.com/watch?v=VIDEO_ID o youtube.com/shorts/VIDEO_ID
  if (uri.host.contains('youtube.com')) {
    final v = uri.queryParameters['v'];
    if (v != null && v.isNotEmpty) return v;
    // /shorts/VIDEO_ID
    if (uri.pathSegments.contains('shorts') && uri.pathSegments.length > 1) {
      return uri.pathSegments[uri.pathSegments.indexOf('shorts') + 1];
    }
  }

  return null;
}

/// URL de la miniatura de YouTube (calidad media).
String youtubeThumbnailUrl(String videoId) {
  return 'https://img.youtube.com/vi/$videoId/mqdefault.jpg';
}

/// URL del embed de YouTube para reproducir dentro de la app (WebView).
String youtubeEmbedUrl(String videoId) {
  return 'https://www.youtube.com/embed/$videoId?playsinline=1';
}

/// HTML con iframe que incluye referrerpolicy para evitar Error 153.
/// YouTube exige referrerpolicy="strict-origin-when-cross-origin" en el embed.
String youtubeEmbedHtml(String videoId) {
  final embedSrc = youtubeEmbedUrl(videoId);
  return '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body { width: 100%; height: 100%; background: #000; }
    iframe { position: absolute; top: 0; left: 0; width: 100%; height: 100%; border: none; }
  </style>
</head>
<body>
  <iframe
    src="$embedSrc"
    referrerpolicy="strict-origin-when-cross-origin"
    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
    allowfullscreen>
  </iframe>
</body>
</html>
''';
}
