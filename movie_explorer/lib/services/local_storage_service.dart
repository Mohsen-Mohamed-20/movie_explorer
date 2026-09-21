import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/movie_model.dart';

/// Saves the favorite movies on the phone using SharedPreferences.
/// Each movie is stored as a JSON string inside one list of strings.
class LocalStorageService {
  static const String _favoritesKey = 'favorite_movies';

  Future<List<MovieModel>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_favoritesKey) ?? <String>[];

    return saved
        .map((text) => MovieModel.fromStorageJson(
              jsonDecode(text) as Map<String, dynamic>,
            ))
        .toList();
  }

  Future<void> saveFavorite(MovieModel movie) async {
    final favorites = await getFavorites();

    // Don't save the same movie twice.
    if (favorites.any((m) => m.id == movie.id)) return;

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
