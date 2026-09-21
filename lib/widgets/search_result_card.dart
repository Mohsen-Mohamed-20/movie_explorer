import 'package:flutter/material.dart';

import '../models/movie_model.dart';
import 'genre_chip.dart';
import 'poster_image.dart';
import 'rating_widget.dart';

/// One row in the Search results list:
/// small poster on the left, details on the right.
class SearchResultCard extends StatelessWidget {
  const SearchResultCard({super.key, required this.movie, required this.onTap});

  final MovieModel movie;
  final VoidCallback onTap;

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 72,
                height: 108,
                child: PosterImage(url: movie.posterUrl),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (movie.genres.isNotEmpty)
                        Flexible(
                          child:
                              GenreChip(label: movie.genres.first, small: true),
                        ),
                      if (movie.genres.isNotEmpty) const SizedBox(width: 8),
                      Text(
                        movie.year,
                        style: TextStyle(fontSize: 12, color: theme.hintColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    movie.overview.isEmpty
                        ? 'No description available.'
                        : movie.overview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: theme.hintColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RatingWidget(rating: movie.rating),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
