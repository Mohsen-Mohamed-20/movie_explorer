import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/movie_cubit.dart';
import '../cubit/movie_state.dart';
import '../models/movie_model.dart';
import '../theme/app_theme.dart';
import '../widgets/genre_chip.dart';
import '../widgets/poster_image.dart';
import '../widgets/primary_button.dart';
import '../widgets/rating_widget.dart';
import 'home_screen.dart';
import 'movie_details_screen.dart';

class PromotionalScreen extends StatelessWidget {
  const PromotionalScreen({super.key});

  // Shown if the API data is not available (yet). This is the featured
  // movie from the Figma design, so this screen never needs its own request.
  static const MovieModel _fallbackMovie = MovieModel(
    id: 'featured_batman',
    title: 'The Batman',
    posterUrl: '',
    backdropUrl: '',
    overview:
        'Darkness has a new hero. In his second year of fighting crime, Batman '
        'uncovers corruption in Gotham City that connects to his own family '
        'while facing a serial killer known as the Riddler.',
    rating: 7.7,
    releaseDate: '2022-03-01',
    genres: ['Action', 'Crime', 'Mystery', 'Thriller'],
  );

  /// Uses the first popular movie that has a backdrop image. If the popular
  /// movies are not loaded, the fallback movie is used.
  MovieModel _pickFeatured(MovieState state) {
    if (state is MovieSuccess) {
      for (final movie in state.movies) {
        if (movie.backdropUrl.isNotEmpty && movie.overview.isNotEmpty) {
          return movie;
        }
      }
    }
    return _fallbackMovie;
  }

  void _goHome(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fadeColor = isDark ? darkBackground : lightBackground;

    return Scaffold(
      body: BlocBuilder<MovieCubit, MovieState>(
        builder: (context, state) {
          final movie = _pickFeatured(state);

          return Stack(
            fit: StackFit.expand,
            children: [
              // 1. Full-screen image
              PosterImage(
                url: movie.backdropUrl.isNotEmpty
                    ? movie.backdropUrl
                    : movie.posterUrl,
              ),
              // 2. Gradient overlay so the text is readable
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      fadeColor.withValues(alpha: 0.15),
                      fadeColor.withValues(alpha: 0.55),
                      fadeColor,
                    ],
                    stops: const [0.0, 0.45, 0.85],
                  ),
                ),
              ),
              // 3. Content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _TopBar(onSkip: () => _goHome(context)),
                      const Spacer(),
                      _FeaturedInfo(movie: movie, isDark: isDark),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onSkip});

  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final pillColor =
        Theme.of(context).colorScheme.surface.withValues(alpha: 0.75);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: pillColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.movie_creation_outlined, size: 18, color: primaryColor),
              SizedBox(width: 8),
              Text(
                'Movie Explorer',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onSkip,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: pillColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Skip',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                SizedBox(width: 6),
                Icon(Icons.arrow_forward, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FeaturedInfo extends StatelessWidget {
  const _FeaturedInfo({required this.movie, required this.isDark});

  final MovieModel movie;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      // Light mode: the info sits on a white card (like in Figma).
      padding: isDark ? EdgeInsets.zero : const EdgeInsets.all(20),
      decoration: isDark
          ? null
          : BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: theme.dividerColor),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'FEATURED MOVIE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: isDark ? secondaryColor : primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              RatingWidget(rating: movie.rating),
              const SizedBox(width: 12),
              Text(
                movie.year,
                style: TextStyle(fontSize: 12, color: theme.hintColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            movie.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            movie.overview,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14, height: 1.5, color: theme.hintColor),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final genre in movie.genres.take(4))
                GenreChip(label: genre, small: true),
            ],
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Explore Movie',
            icon: Icons.play_arrow_rounded,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MovieDetailsScreen(movie: movie),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          // Page indicator (static): first dot is active.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _dot(width: 24, color: primaryColor),
              _dot(width: 8, color: theme.hintColor.withValues(alpha: 0.4)),
              _dot(width: 8, color: theme.hintColor.withValues(alpha: 0.4)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dot({required double width, required Color color}) {
    return Container(
      width: width,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
