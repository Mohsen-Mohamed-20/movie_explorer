import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/movie_model.dart';

/// Saves the favorite movies on the phone using SharedPreferences.
/// Each movie is stored as a JSON string inside one list of strings.
class LocalStorageService {
  static const String _favoritesKey = 'favorite_movies';

  Future<List<MovieModel>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final saved = prefs.getStringList(_favoritesKey) ?? <String>[];

    final favorites = <MovieModel>[];
    for (final text in saved) {
      try {
        favorites.add(
          MovieModel.fromStorageJson(
            jsonDecode(text) as Map<String, dynamic>,
          ),
        );
      } catch (_) {
        // Ignore old or corrupted favorite entries instead of hiding the list.
      }
    }

    return favorites;
  }

  Future<void> saveFavorite(MovieModel movie) async {
    final favorites = await getFavorites();

    favorites.removeWhere((m) => m.id == movie.id);

    favorites.insert(0, movie); // newest first
    await _writeFavorites(favorites);
  }

  Future<void> removeFavorite(String movieId) async {
    final favorites = await getFavorites();
    favorites.removeWhere((m) => m.id == movieId);
    await _writeFavorites(favorites);
  }

  Future<bool> isFavorite(String movieId) async {
    final favorites = await getFavorites();
    return favorites.any((m) => m.id == movieId);
  }

  Future<void> _writeFavorites(List<MovieModel> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final asText = favorites.map((m) => jsonEncode(m.toJson())).toList();
    await prefs.setStringList(_favoritesKey, asText);
  }
}
