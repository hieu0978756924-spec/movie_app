import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/cast.dart';
import '../../domain/usecases/get_movie_credits_usecase.dart';
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
  final List<Cast> castList;

  const MovieDetailLoadedState(this.movie, {this.castList = const []});

  MovieDetailLoadedState copyWith({
    Movie? movie,
    List<Cast>? castList,
  }) {
    return MovieDetailLoadedState(
      movie ?? this.movie,
      castList: castList ?? this.castList,
    );
  }

  @override
  List<Object?> get props => [movie, castList];
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
  final GetMovieCreditsUseCase getMovieCreditsUseCase;

  MovieDetailBloc(
    this.getMovieDetailUseCase,
    this.getMovieCreditsUseCase,
  ) : super(MovieDetailInitialState()) {
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

    final detailFuture = getMovieDetailUseCase(event.movieId);
    final creditsFuture = getMovieCreditsUseCase(event.movieId);

    final results = await Future.wait([detailFuture, creditsFuture]);
    final detailResult = results[0] as Either<Failure, Movie>;
    final creditsResult = results[1] as Either<Failure, List<Cast>>;

    Movie movie = event.initialMovie ??
        Movie(
          id: event.movieId,
          tenPhim: '',
          hinhAnh: '',
          moTa: '',
          diemDanhGia: 0,
        );

    detailResult.fold(
      (failure) {},
      (fetchedMovie) => movie = fetchedMovie,
    );

    List<Cast> castList = [];
    creditsResult.fold(
      (failure) {},
      (fetchedCast) => castList = fetchedCast,
    );

    if (movie.tenPhim.isNotEmpty || event.initialMovie != null) {
      emit(MovieDetailLoadedState(movie, castList: castList));
    } else {
      emit(MovieDetailErrorState(
        'Lỗi lấy chi tiết phim',
        initialMovie: event.initialMovie,
      ));
    }
  }

  void _onToggleFavorite(
      ToggleFavoriteMovieEvent event, Emitter<MovieDetailState> emit) {
    if (state is MovieDetailLoadedState) {
      final currentState = state as MovieDetailLoadedState;
      final updatedMovie =
          currentState.movie.copyWith(yeuThich: !currentState.movie.yeuThich);
      emit(currentState.copyWith(movie: updatedMovie));
    }
  }
}

