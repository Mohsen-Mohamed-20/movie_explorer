import 'package:flutter/material.dart';

import '../models/movie_model.dart';
import '../theme/app_theme.dart';
import 'genre_chip.dart';
import 'poster_image.dart';
import 'rating_widget.dart';

/// One row in the Favorites list, with a heart button to remove the movie.
class FavoriteMovieCard extends StatelessWidget {
  const FavoriteMovieCard({
    super.key,
    required this.movie,
    required this.onTap,
    required this.onRemove,
  });

  final MovieModel movie;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 64,
                height: 96,
                child: PosterImage(url: movie.posterUrl),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      RatingWidget(rating: movie.rating),
                      const SizedBox(width: 12),
                      Text(
                        movie.year,
                        style: TextStyle(fontSize: 12, color: theme.hintColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final genre in movie.genres.take(2))
                        GenreChip(label: genre, small: true),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Remove from favorites',
              onPressed: onRemove,
              icon: const Icon(Icons.favorite, color: primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
