import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/movie_model.dart';

/// Thrown when the app was started without a TMDB API key.
class ApiKeyMissingException implements Exception {
  @override
  String toString() =>
      'TMDB API key is missing.\nRun the app with:\nflutter run --dart-define=TMDB_API_KEY=your_key';
}

/// Talks to the TMDB REST API (https://developer.themoviedb.org).
/// This class only sends requests and converts JSON -> MovieModel.
/// It contains no UI code.
class MovieApiService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  // The key is NOT written in the code, so it never ends up on GitHub.
  // Pass it when running:  --dart-define=TMDB_API_KEY=your_key
  static const String _apiKey = String.fromEnvironment('TMDB_API_KEY');

  Future<List<MovieModel>> getPopularMovies() {
    return _getMovies('/movie/popular', {});
  }

  Future<List<MovieModel>> searchMovies(String query) {
    return _getMovies('/search/movie', {'query': query});
  }

  Future<MovieModel> getMovieDetails(MovieModel movie) async {
    if (_apiKey.isEmpty) throw ApiKeyMissingException();

    final uri = Uri.parse('$_baseUrl/movie/${movie.id}').replace(
      queryParameters: {
        'api_key': _apiKey,
        'language': 'en-US',
        'append_to_response': 'credits,videos',
      },
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Request failed with status ${response.statusCode}');
    }

    return MovieModel.fromDetailsJson(
      jsonDecode(response.body) as Map<String, dynamic>,
      fallback: movie,
    );
  }

  Future<List<MovieModel>> _getMovies(
    String path,
    Map<String, String> extraParams,
  ) async {
    if (_apiKey.isEmpty) throw ApiKeyMissingException();

    final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: {
      'api_key': _apiKey,
      'language': 'en-US',
      'page': '1',
      ...extraParams,
    });

    final response = await http.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Request failed with status ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>;

    return results
        .map((item) => MovieModel.fromJson(item as Map<String, dynamic>))
        .where(
            (movie) => movie.posterUrl.isNotEmpty) // skip movies with no poster
        .toList();
  }
}
