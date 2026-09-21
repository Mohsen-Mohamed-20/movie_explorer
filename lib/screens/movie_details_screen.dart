import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../cubit/movie_cubit.dart';
import '../models/movie_model.dart';
import '../theme/app_theme.dart';
import '../widgets/genre_chip.dart';
import '../widgets/poster_image.dart';
import '../widgets/primary_button.dart';
import '../widgets/rating_widget.dart';

class MovieDetailsScreen extends StatelessWidget {
  const MovieDetailsScreen({super.key, required this.movie});

  /// The movie is passed from the previous screen - no new API call needed.
  final MovieModel movie;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MovieCubit(),
      child: _DetailsView(movie: movie),
    );
  }
}

class _DetailsView extends StatefulWidget {
  const _DetailsView({required this.movie});

  final MovieModel movie;

  @override
  State<_DetailsView> createState() => _DetailsViewState();
}

class _DetailsViewState extends State<_DetailsView> {
  bool _isFavorite = false;
  late MovieModel _movie = widget.movie;
  bool _loadingDetails = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
    _loadDetails();
  }

  Future<void> _loadFavoriteStatus() async {
    final cubit = context.read<MovieCubit>();
    final favorite = await cubit.isFavorite(widget.movie.id);
    if (!mounted) return;
    setState(() => _isFavorite = favorite);
  }

  Future<void> _loadDetails() async {
    final cubit = context.read<MovieCubit>();

    try {
      final details = await cubit.loadMovieDetails(widget.movie);
      if (!mounted) return;
      setState(() {
        _movie = details;
        _loadingDetails = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingDetails = false);
    }
  }

  Future<void> _toggleFavorite() async {
    final cubit = context.read<MovieCubit>();
    final messenger = ScaffoldMessenger.of(context);

    final nowFavorite = await cubit.toggleFavorite(_movie);
    if (!mounted) return;

    setState(() => _isFavorite = nowFavorite);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 1),
        content: Text(
          nowFavorite ? 'Added to favorites' : 'Removed from favorites',
        ),
      ),
    );
  }

  Future<void> _openTrailer() async {
    if (_movie.trailerUrl.isEmpty) return;

    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.parse(_movie.trailerUrl);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened && mounted) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not open trailer')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final movie = _movie;

    final width = MediaQuery.of(context).size.width;
    final double posterWidth = (width * 0.55).clamp(150.0, 240.0).toDouble();

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 380,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Opacity(
                  opacity: isDark ? 0.5 : 0.28,
                  child: PosterImage(
                    url: movie.backdropUrl.isNotEmpty
                        ? movie.backdropUrl
                        : movie.posterUrl,
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.scaffoldBackgroundColor.withValues(alpha: 0.1),
                        theme.scaffoldBackgroundColor,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Top bar: back button + favorite heart
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CircleButton(
                        icon: Icons.arrow_back,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      _CircleButton(
                        icon: _isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: _isFavorite ? primaryColor : null,
                        onTap: _toggleFavorite,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Column(
                      children: [
                        // Poster
                        Container(
                          width: posterWidth,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.3),
                                blurRadius: 32,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: AspectRatio(
                              aspectRatio: 2 / 3,
                              child: PosterImage(url: movie.posterUrl),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          movie.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Rating + year
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: theme.dividerColor),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  RatingWidget(
                                      rating: movie.rating, fontSize: 14),
                                  Text(
                                    ' / 10',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.hintColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (movie.year.isNotEmpty) ...[
                              const SizedBox(width: 12),
                              Text(
                                movie.year,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.hintColor,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Genre chips
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final genre in movie.genres)
                              GenreChip(label: genre),
                          ],
                        ),
                        const SizedBox(height: 24),
                        if (_loadingDetails) ...[
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(height: 20),
                        ],
                        if (movie.trailerUrl.isNotEmpty) ...[
                          PrimaryButton(
                            label: 'Watch Trailer',
                            icon: Icons.play_arrow_rounded,
                            onPressed: _openTrailer,
                          ),
                          const SizedBox(height: 24),
                        ],
                        if (movie.cast.isNotEmpty) ...[
                          _SectionTitle(label: 'Cast'),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 150,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: movie.cast.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                return _CastCard(member: movie.cast[index]);
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        // Overview
                        const _SectionTitle(label: 'Overview'),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            movie.overview.isEmpty
                                ? 'No description available.'
                                : movie.overview,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              color: theme.hintColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Favorite action button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: PrimaryButton(
                    label: _isFavorite
                        ? 'Remove from Favorites'
                        : 'Add to Favorites',
                    icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
                    onPressed: _toggleFavorite,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _CastCard extends StatelessWidget {
  const _CastCard({required this.member});

  final CastMember member;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 86,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 72,
              height: 72,
              child: PosterImage(url: member.profileUrl),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            member.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 3),
          Text(
            member.character,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: theme.hintColor),
          ),
        ],
      ),
    );
  }
}

/// Small round button used for the back arrow and the heart.
class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap, this.color});

  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface.withValues(alpha: 0.8),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 22, color: color),
        ),
      ),
    );
  }
}
