import '../models/movie_model.dart';

abstract class MovieState {}

/// Nothing has been requested yet.
class MovieInitial extends MovieState {}

/// A request is running -> show a loading spinner.
class MovieLoading extends MovieState {}

/// Data arrived -> show the movies.
class MovieSuccess extends MovieState {
  final List<MovieModel> movies;
  MovieSuccess(this.movies);
}

/// Request worked, but there is nothing to show.
class MovieEmpty extends MovieState {}

/// Something failed -> show an error message.
class MovieError extends MovieState {
  final String message;
  MovieError(this.message);
}
