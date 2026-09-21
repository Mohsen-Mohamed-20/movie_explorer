import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/movie_cubit.dart';
import '../cubit/movie_state.dart';
import '../models/movie_model.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/brand_title.dart';
import '../widgets/favorite_movie_card.dart';
import '../widgets/message_view.dart';
import '../widgets/theme_toggle_button.dart';
import 'movie_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Its own MovieCubit that loads the saved movies right away.
    return BlocProvider(
      create: (_) => MovieCubit()..loadFavorites(),
      child: const _FavoritesView(),
    );
  }
}

class _FavoritesView extends StatelessWidget {
  const _FavoritesView();

  Future<void> _openDetails(BuildContext context, MovieModel movie) async {
    final cubit = context.read<MovieCubit>();
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MovieDetailsScreen(movie: movie)),
    );
    // The user may have removed the movie on the details screen.
    if (!cubit.isClosed) cubit.loadFavorites(showLoading: false);
  }

  Future<void> _remove(BuildContext context, MovieModel movie) async {
    final cubit = context.read<MovieCubit>();
    await cubit.toggleFavorite(movie); // it is a favorite, so this removes it
    if (!cubit.isClosed) cubit.loadFavorites(showLoading: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const BrandTitle(),
        actions: const [ThemeToggleButton(), SizedBox(width: 8)],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      body: BlocBuilder<MovieCubit, MovieState>(
        builder: (context, state) {
          // Loading
          if (state is MovieInitial || state is MovieLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error
          if (state is MovieError) {
            return MessageView(
              icon: Icons.error_outline,
              iconColor: errorColor,
              title: 'Something went wrong',
              message: state.message,
              buttonLabel: 'Try Again',
              onPressed: () => context.read<MovieCubit>().loadFavorites(),
            );
          }

          // Empty: no favorites yet
          if (state is! MovieSuccess) {
            return MessageView(
              icon: Icons.favorite_border,
              title: 'No favorites yet',
              message: 'Start exploring movies\nand save the ones you love.',
              buttonLabel: 'Explore Movies',
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            );
          }

          // Success: list of saved movies
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Row(
                  children: [
                    const Text(
                      'My Favorites',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${state.movies.length} '
                        '${state.movies.length == 1 ? 'title' : 'titles'}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: secondaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: state.movies.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final movie = state.movies[index];
                    return FavoriteMovieCard(
                      movie: movie,
                      onTap: () => _openDetails(context, movie),
                      onRemove: () => _remove(context, movie),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
