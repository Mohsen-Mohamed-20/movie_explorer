const String _imageBaseUrl = 'https://image.tmdb.org/t/p';

/// The movie list endpoints only return genre IDs, so we translate the
/// IDs to names ourselves. These IDs are TMDB's official genre IDs.
const Map<int, String> genreNames = {
  28: 'Action',
  12: 'Adventure',
  16: 'Animation',
  35: 'Comedy',
  80: 'Crime',
  99: 'Documentary',
  18: 'Drama',
  10751: 'Family',
  14: 'Fantasy',
  36: 'History',
  27: 'Horror',
  10402: 'Music',
  9648: 'Mystery',
  10749: 'Romance',
  878: 'Sci-Fi',
  10770: 'TV Movie',
  53: 'Thriller',
  10752: 'War',
  37: 'Western',
};

class MovieModel {
  final String id;
  final String title;
  final String posterUrl;
  final String backdropUrl;
  final String overview;
  final double rating;
  final String releaseDate;
  final List<String> genres;

  const MovieModel({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.backdropUrl,
    required this.overview,
    required this.rating,
    required this.releaseDate,
    required this.genres,
  });

  /// "2008-07-18" -> "2008"
  String get year =>
      releaseDate.length >= 4 ? releaseDate.substring(0, 4) : '';

  /// Builds a MovieModel from ONE movie object of the TMDB API response
  /// (fields: id, title, poster_path, backdrop_path, overview,
  /// vote_average, release_date, genre_ids).
  factory MovieModel.fromJson(Map<String, dynamic> json) {
    final posterPath = json['poster_path'];
    final backdropPath = json['backdrop_path'];
    final genreIds = (json['genre_ids'] as List<dynamic>?) ?? <dynamic>[];

    return MovieModel(
      id: json['id'].toString(),
      title: (json['title'] ?? 'Untitled').toString(),
      posterUrl: posterPath == null ? '' : '$_imageBaseUrl/w500$posterPath',
      backdropUrl:
          backdropPath == null ? '' : '$_imageBaseUrl/w780$backdropPath',
      overview: (json['overview'] ?? '').toString(),
      rating: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      releaseDate: (json['release_date'] ?? '').toString(),
      genres: genreIds.map((id) => genreNames[id]).whereType<String>().toList(),
    );
  }

  /// Used to save a favorite in SharedPreferences.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'posterUrl': posterUrl,
      'backdropUrl': backdropUrl,
      'overview': overview,
      'rating': rating,
      'releaseDate': releaseDate,
      'genres': genres,
    };
  }

  /// Reads a movie that was saved with [toJson].
  factory MovieModel.fromStorageJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] as String,
      title: json['title'] as String,
      posterUrl: json['posterUrl'] as String,
      backdropUrl: json['backdropUrl'] as String,
      overview: json['overview'] as String,
      rating: (json['rating'] as num).toDouble(),
      releaseDate: json['releaseDate'] as String,
      genres: List<String>.from(json['genres'] as List<dynamic>),
    );
  }
}
