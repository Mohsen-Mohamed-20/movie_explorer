import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/movie_cubit.dart';
import '../cubit/movie_state.dart';
import '../models/movie_model.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/brand_title.dart';
import '../widgets/genre_chip.dart';
import '../widgets/message_view.dart';
import '../widgets/movie_card.dart';
import '../widgets/search_bar.dart';
import '../widgets/theme_toggle_button.dart';
import 'movie_details_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<String> _genres = [
    'All',
    'Sci-Fi',
    'Action',
    'Drama',
    'Thriller',
  ];

  String _selectedGenre = 'All';

  void _openDetails(MovieModel movie) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MovieDetailsScreen(movie: movie)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const BrandTitle(),
        actions: const [ThemeToggleButton(), SizedBox(width: 8)],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search entry point: tapping it opens the Search screen.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: MovieSearchBar(
              readOnly: true,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                );
              },
            ),
          ),
          // Genre filter chips
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _genres.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final genre = _genres[index];
                return GenreChip(
                  label: genre,
                  selected: genre == _selectedGenre,
                  onTap: () => setState(() => _selectedGenre = genre),
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Text(
              'Popular Movies',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: BlocBuilder<MovieCubit, MovieState>(
              builder: (context, state) => _buildBody(context, state),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, MovieState state) {
    // Loading (or not started yet)
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
        onPressed: () => context.read<MovieCubit>().loadPopularMovies(),
      );
    }

    // Success
    if (state is MovieSuccess) {
      final movies = _selectedGenre == 'All'
          ? state.movies
          : state.movies.where((m) => m.genres.contains(_selectedGenre)).toList();

      if (movies.isEmpty) {
        return const MessageView(
          icon: Icons.movie_filter_outlined,
          title: 'No movies found',
          message: 'Try selecting another genre.',
        );
      }

      // 2 columns on phones, more on wider screens.
      final width = MediaQuery.of(context).size.width;
      final columns = width >= 900 ? 4 : (width >= 600 ? 3 : 2);

      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.58,
        ),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return MovieCard(movie: movie, onTap: () => _openDetails(movie));
        },
      );
    }

    // Empty (the API returned no movies)
    return const MessageView(
      icon: Icons.movie_filter_outlined,
      title: 'No movies found',
      message: 'Try again later.',
    );
  }
}
