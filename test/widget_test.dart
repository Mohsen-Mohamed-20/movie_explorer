import 'package:flutter_test/flutter_test.dart';
import 'package:movie_explorer/models/movie_model.dart';

void main() {
  test('MovieModel.fromJson reads the TMDB fields', () {
    final movie = MovieModel.fromJson({
      'id': 155,
      'title': 'The Dark Knight',
      'poster_path': '/abc.jpg',
      'backdrop_path': null,
      'overview': 'Some text',
      'vote_average': 8.5,
      'release_date': '2008-07-16',
      'genre_ids': [28, 80, 18],
    });

    expect(movie.id, '155');
    expect(movie.year, '2008');
    expect(movie.rating, 8.5);
    expect(movie.posterUrl, 'https://image.tmdb.org/t/p/w500/abc.jpg');
    expect(movie.backdropUrl, '');
    expect(movie.genres, ['Action', 'Crime', 'Drama']);
  });

  test('MovieModel can be saved and read back (favorites)', () {
    const movie = MovieModel(
      id: '1',
      title: 'Inception',
      posterUrl: 'https://example.com/p.jpg',
      backdropUrl: '',
      overview: 'Dreams',
      rating: 8.8,
      releaseDate: '2010-07-16',
      genres: ['Action', 'Sci-Fi'],
    );

    final copy = MovieModel.fromStorageJson(movie.toJson());

    expect(copy.id, movie.id);
    expect(copy.title, movie.title);
    expect(copy.rating, movie.rating);
    expect(copy.genres, movie.genres);
  });
}
