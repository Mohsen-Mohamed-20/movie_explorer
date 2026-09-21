import 'package:flutter/material.dart';

/// Shows a network image. While it loads (or if it fails, or there is no
/// URL) a simple placeholder is shown so the layout never looks broken.
class PosterImage extends StatelessWidget {
  const PosterImage({super.key, required this.url, this.fit = BoxFit.cover});

  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final placeholder = ColoredBox(
      color: theme.cardColor,
      child: Center(
        child: Icon(Icons.movie_outlined, size: 32, color: theme.hintColor),
      ),
    );

    if (url.isEmpty) return placeholder;

    return Image.network(
      url,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        return progress == null ? child : placeholder;
      },
      errorBuilder: (context, error, stackTrace) => placeholder,
    );
  }
}
