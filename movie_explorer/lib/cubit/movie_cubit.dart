import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/movie_model.dart';
import '../services/local_storage_service.dart';
import '../services/movie_api_service.dart';
import 'movie_state.dart';

/// Controls the movie-related state.
///
/// The app creates one MovieCubit for the Home/Promotional screens (popular
/// movies) and a fresh one inside the Search, Favorites and Details screens.
/// That way search results never replace the popular movies on Home.
class MovieCubit extends Cubit<MovieState> {
  final MovieApiService _api;
  final LocalStorageService _storage;

  MovieCubit({MovieApiService? api, LocalStorageService? storage})
      : _api = api ?? MovieApiService(),
        _storage = storage ?? LocalStorageService(),
        super(MovieInitial());

  Future<void> loadPopularMovies() async {
    _safeEmit(MovieLoading());
    try {
      final movies = await _api.getPopularMovies();
      _emitMovies(movies);
    } catch (error) {
      _safeEmit(MovieError(_messageFor(error)));
    }
  }

  Future<void> searchMovies(String query) async {
    final text = query.trim();
    if (text.isEmpty) return; // the Search screen validates this too

    _safeEmit(MovieLoading());
    try {
      final movies = await _api.searchMovies(text);
      _emitMovies(movies);
    } catch (error) {
      _safeEmit(MovieError(_messageFor(error)));
    }
  }

  /// Set [showLoading] to false to refresh the list without a spinner.
  Future<void> loadFavorites({bool showLoading = true}) async {
    if (showLoading) _safeEmit(MovieLoading());
    try {
      final movies = await _storage.getFavorites();
      _emitMovies(movies);
    } catch (error) {
      _safeEmit(MovieError(_messageFor(error)));
    }
  }

  /// Adds the movie to favorites, or removes it if it is already there.
  /// Returns true if the movie is a favorite AFTER the change.
  Future<bool> toggleFavorite(MovieModel movie) async {
    final alreadyFavorite = await _storage.isFavorite(movie.id);
    if (alreadyFavorite) {
      await _storage.removeFavorite(movie.id);
      return false;
    }
    await _storage.saveFavorite(movie);
    return true;
  }

  Future<bool> isFavorite(String movieId) => _storage.isFavorite(movieId);

  /// The user can leave a screen while a request is still running.
  /// Emitting on a closed Cubit would crash, so we check first.
  void _safeEmit(MovieState newState) {
    if (!isClosed) emit(newState);
  }

  void _emitMovies(List<MovieModel> movies) {
    if (movies.isEmpty) {
      _safeEmit(MovieEmpty());
    } else {
      _safeEmit(MovieSuccess(movies));
    }
  }

  String _messageFor(Object error) {
    if (error is ApiKeyMissingException) return error.toString();
    return 'Please try again.';
  }
}
