import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/movie_cubit.dart';
import '../cubit/movie_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/message_view.dart';
import '../widgets/primary_button.dart';
import '../widgets/search_bar.dart';
import '../widgets/search_result_card.dart';
import '../widgets/theme_toggle_button.dart';
import 'movie_details_screen.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Its own MovieCubit, so search results don't replace Home's movies.
    return BlocProvider(
      create: (_) => MovieCubit(),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  String _lastQuery = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a movie name';
    }
    return null;
  }

  void _search() {
    // Validation: an empty field never reaches the API.
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    _lastQuery = _controller.text.trim();
    context.read<MovieCubit>().searchMovies(_lastQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Movies'),
        actions: const [ThemeToggleButton(), SizedBox(width: 8)],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: MovieSearchBar(
                      controller: _controller,
                      hintText: 'Enter movie name',
                      validator: _validate,
                      onSubmitted: (_) => _search(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  PrimaryButton(
                    label: 'Search',
                    expand: false,
                    height: 52,
                    onPressed: _search,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<MovieCubit, MovieState>(
              builder: (context, state) => _buildResults(context, state),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(BuildContext context, MovieState state) {
    // Initial
    if (state is MovieInitial) {
      return const MessageView(
        icon: Icons.search,
        title: 'Search for your favorite movies',
        message: 'Enter a movie name to get started.',
      );
    }

    // Loading
    if (state is MovieLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Searching...'),
          ],
        ),
      );
    }

    // Success
    if (state is MovieSuccess) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                const Text(
                  'Search Results',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${state.movies.length}',
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
                return SearchResultCard(
                  movie: movie,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MovieDetailsScreen(movie: movie),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      );
    }

    // Empty
    if (state is MovieEmpty) {
      return const MessageView(
        icon: Icons.search_off,
        title: 'No movies found',
        message: 'Try searching for another movie.',
      );
    }

    // Error
    final message = state is MovieError ? state.message : 'Please try again.';
    return MessageView(
      icon: Icons.error_outline,
      iconColor: errorColor,
      title: 'Something went wrong',
      message: message,
      buttonLabel: 'Try Again',
      onPressed: () => context.read<MovieCubit>().searchMovies(_lastQuery),
    );
  }
}
