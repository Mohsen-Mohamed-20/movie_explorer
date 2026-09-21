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
  final List<CastMember> cast;
  final String trailerUrl;

  const MovieModel({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.backdropUrl,
    required this.overview,
    required this.rating,
    required this.releaseDate,
    required this.genres,
    this.cast = const [],
    this.trailerUrl = '',
  });

  /// "2008-07-18" -> "2008"
  String get year => releaseDate.length >= 4 ? releaseDate.substring(0, 4) : '';

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

  factory MovieModel.fromDetailsJson(
    Map<String, dynamic> json, {
    MovieModel? fallback,
  }) {
    final base = MovieModel.fromJson({
      ...json,
      'genre_ids': (json['genres'] as List<dynamic>?)
              ?.map((genre) => (genre as Map<String, dynamic>)['id'])
              .toList() ??
          <dynamic>[],
    });

    final castJson = ((json['credits'] as Map<String, dynamic>?)?['cast']
            as List<dynamic>?) ??
        <dynamic>[];
    final videosJson = ((json['videos'] as Map<String, dynamic>?)?['results']
            as List<dynamic>?) ??
        <dynamic>[];

    final videos = videosJson
        .whereType<Map<String, dynamic>>()
        .where((video) =>
            video['site'] == 'YouTube' &&
            (video['type'] == 'Trailer' || video['type'] == 'Teaser') &&
            video['key'] != null)
        .map(_MovieVideo.fromJson)
        .toList()
      ..sort((a, b) => b.trailerScore.compareTo(a.trailerScore));

    final trailer = videos.firstOrNull?.youtubeUrl;

    return base.copyWith(
      posterUrl:
          base.posterUrl.isNotEmpty ? base.posterUrl : fallback?.posterUrl,
      backdropUrl: base.backdropUrl.isNotEmpty
          ? base.backdropUrl
          : fallback?.backdropUrl,
      overview: base.overview.isNotEmpty ? base.overview : fallback?.overview,
      rating: base.rating == 0 ? fallback?.rating : base.rating,
      releaseDate: base.releaseDate.isNotEmpty
          ? base.releaseDate
          : fallback?.releaseDate,
      genres: base.genres.isNotEmpty ? base.genres : fallback?.genres,
      cast: castJson
          .whereType<Map<String, dynamic>>()
          .map(CastMember.fromJson)
          .where((member) => member.name.isNotEmpty)
          .take(12)
          .toList(),
      trailerUrl: trailer ?? fallback?.trailerUrl,
    );
  }

  MovieModel copyWith({
    String? title,
    String? posterUrl,
    String? backdropUrl,
    String? overview,
    double? rating,
    String? releaseDate,
    List<String>? genres,
    List<CastMember>? cast,
    String? trailerUrl,
  }) {
    return MovieModel(
      id: id,
      title: title ?? this.title,
      posterUrl: posterUrl ?? this.posterUrl,
      backdropUrl: backdropUrl ?? this.backdropUrl,
      overview: overview ?? this.overview,
      rating: rating ?? this.rating,
      releaseDate: releaseDate ?? this.releaseDate,
      genres: genres ?? this.genres,
      cast: cast ?? this.cast,
      trailerUrl: trailerUrl ?? this.trailerUrl,
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
      'cast': cast.map((member) => member.toJson()).toList(),
      'trailerUrl': trailerUrl,
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
      cast: ((json['cast'] as List<dynamic>?) ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(CastMember.fromStorageJson)
          .toList(),
      trailerUrl: (json['trailerUrl'] ?? '').toString(),
    );
  }
}

class _MovieVideo {
  final String key;
  final String name;
  final String type;
  final bool official;

  const _MovieVideo({
    required this.key,
    required this.name,
    required this.type,
    required this.official,
  });

  factory _MovieVideo.fromJson(Map<String, dynamic> json) {
    return _MovieVideo(
      key: (json['key'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      official: json['official'] == true,
    );
  }

  String get youtubeUrl => 'https://www.youtube.com/watch?v=$key';

  int get trailerScore {
    final lowerName = name.toLowerCase();
    var score = 0;

    if (type == 'Trailer') score += 100;
    if (official) score += 50;
    if (lowerName.contains('official trailer')) score += 40;
    if (lowerName.contains('final trailer')) score += 20;
    if (lowerName.contains('full trailer')) score += 20;
    if (lowerName.contains('main trailer')) score += 15;
    if (type == 'Teaser' || lowerName.contains('teaser')) score -= 80;
    if (lowerName.contains('clip')) score -= 60;
    if (lowerName.contains('tv spot')) score -= 60;

    return score;
  }
}

class CastMember {
  final String id;
  final String name;
  final String character;
  final String profileUrl;

  const CastMember({
    required this.id,
    required this.name,
    required this.character,
    required this.profileUrl,
  });

  factory CastMember.fromJson(Map<String, dynamic> json) {
    final profilePath = json['profile_path'];

    return CastMember(
      id: json['id'].toString(),
      name: (json['name'] ?? '').toString(),
      character: (json['character'] ?? '').toString(),
      profileUrl: profilePath == null ? '' : '$_imageBaseUrl/w185$profilePath',
    );
  }

  factory CastMember.fromStorageJson(Map<String, dynamic> json) {
    return CastMember(
      id: json['id'] as String,
      name: json['name'] as String,
      character: json['character'] as String,
      profileUrl: json['profileUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'character': character,
      'profileUrl': profileUrl,
    };
  }
}
