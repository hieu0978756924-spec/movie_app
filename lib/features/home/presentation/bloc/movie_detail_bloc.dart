import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/get_movie_detail_usecase.dart';
import '../../models/movie.dart';

// Events
abstract class MovieDetailEvent extends Equatable {
  const MovieDetailEvent();
  @override
  List<Object?> get props => [];
}

class FetchMovieDetailEvent extends MovieDetailEvent {
  final int movieId;
  final Movie? initialMovie;

  const FetchMovieDetailEvent(this.movieId, {this.initialMovie});

  @override
  List<Object?> get props => [movieId, initialMovie];
}

class ToggleFavoriteMovieEvent extends MovieDetailEvent {}

// States
abstract class MovieDetailState extends Equatable {
  const MovieDetailState();
  @override
  List<Object?> get props => [];
}

class MovieDetailInitialState extends MovieDetailState {}

class MovieDetailLoadingState extends MovieDetailState {
  final Movie? initialMovie;
  const MovieDetailLoadingState({this.initialMovie});

  @override
  List<Object?> get props => [initialMovie];
}

class MovieDetailLoadedState extends MovieDetailState {
  final Movie movie;
  const MovieDetailLoadedState(this.movie);

  MovieDetailLoadedState copyWith({Movie? movie}) {
    return MovieDetailLoadedState(movie ?? this.movie);
  }

  @override
  List<Object?> get props => [movie];
}

class MovieDetailErrorState extends MovieDetailState {
  final String message;
  final Movie? initialMovie;

  const MovieDetailErrorState(this.message, {this.initialMovie});

  @override
  List<Object?> get props => [message, initialMovie];
}

@injectable
class MovieDetailBloc extends Bloc<MovieDetailEvent, MovieDetailState> {
  final GetMovieDetailUseCase getMovieDetailUseCase;

  MovieDetailBloc(this.getMovieDetailUseCase)
      : super(MovieDetailInitialState()) {
    on<FetchMovieDetailEvent>(_onFetchMovieDetail);
    on<ToggleFavoriteMovieEvent>(_onToggleFavorite);
  }

  Future<void> _onFetchMovieDetail(
      FetchMovieDetailEvent event, Emitter<MovieDetailState> emit) async {
    emit(MovieDetailLoadingState(initialMovie: event.initialMovie));

    if (event.movieId == 0 && event.initialMovie != null) {
      emit(MovieDetailLoadedState(event.initialMovie!));
      return;
    }

    final result = await getMovieDetailUseCase(event.movieId);
    result.fold(
      (failure) {
        if (event.initialMovie != null) {
          emit(MovieDetailLoadedState(event.initialMovie!));
        } else {
          emit(MovieDetailErrorState(failure.message,
              initialMovie: event.initialMovie));
        }
      },
      (movie) => emit(MovieDetailLoadedState(movie)),
    );
  }

  void _onToggleFavorite(
      ToggleFavoriteMovieEvent event, Emitter<MovieDetailState> emit) {
    if (state is MovieDetailLoadedState) {
      final currentMovie = (state as MovieDetailLoadedState).movie;
      final updatedMovie =
          currentMovie.copyWith(yeuThich: !currentMovie.yeuThich);
      emit(MovieDetailLoadedState(updatedMovie));
    }
  }
}
