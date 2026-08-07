import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:movie_app/features/home/models/movie.dart';
import 'package:movie_app/features/watchlist/domain/entities/watchlist_item.dart';
import 'package:movie_app/features/watchlist/domain/repositories/watchlist_repository.dart';
import 'package:movie_app/features/watchlist/presentation/bloc/watchlist_bloc.dart';
import 'package:movie_app/features/watchlist/presentation/bloc/watchlist_event.dart';
import 'package:movie_app/features/watchlist/presentation/bloc/watchlist_state.dart';

class MockWatchlistRepository extends Mock implements WatchlistRepository {}

void main() {
  late MockWatchlistRepository mockRepository;
  late WatchlistBloc watchlistBloc;

  setUp(() {
    mockRepository = MockWatchlistRepository();
    watchlistBloc = WatchlistBloc(mockRepository);
    registerFallbackValue(
      WatchlistItem(
        id: 1,
        tenPhim: 'Test Movie',
        hinhAnh: '/poster.jpg',
        diemDanhGia: 8.5,
        addedAt: DateTime.now(),
      ),
    );
  });

  final tItem = WatchlistItem(
    id: 1,
    tenPhim: 'Avatar 3',
    hinhAnh: '/avatar3.jpg',
    backdropPath: '/avatar3_bg.jpg',
    diemDanhGia: 9.0,
    theLoai: 'Sci-Fi',
    namPhatHanh: 2026,
    daXem: false,
    addedAt: DateTime.parse('2026-08-07T10:00:00.000'),
  );

  final tMovie = Movie(
    id: 1,
    tenPhim: 'Avatar 3',
    hinhAnh: '/avatar3.jpg',
    backdropPath: '/avatar3_bg.jpg',
    diemDanhGia: 9.0,
    theLoai: 'Sci-Fi',
    namPhatHanh: 2026,
    moTa: 'Pandora adventures',
  );

  group('WatchlistBloc Tests', () {
    test('initial state is WatchlistInitialState', () {
      expect(watchlistBloc.state, equals(const WatchlistInitialState()));
    });

    blocTest<WatchlistBloc, WatchlistState>(
      'emits [WatchlistLoadingState, WatchlistLoadedState] when LoadWatchlistEvent is added and succeeds',
      build: () {
        when(() => mockRepository.getWatchlist())
            .thenAnswer((_) async => Right([tItem]));
        return watchlistBloc;
      },
      act: (bloc) => bloc.add(const LoadWatchlistEvent()),
      expect: () => [
        const WatchlistLoadingState(),
        WatchlistLoadedState(items: [tItem]),
      ],
    );

    blocTest<WatchlistBloc, WatchlistState>(
      'emits WatchlistLoadedState when AddMovieToWatchlistEvent is added',
      build: () {
        when(() => mockRepository.addToWatchlist(tMovie))
            .thenAnswer((_) async => const Right(null));
        when(() => mockRepository.getWatchlist())
            .thenAnswer((_) async => Right([tItem]));
        return watchlistBloc;
      },
      act: (bloc) => bloc.add(AddMovieToWatchlistEvent(tMovie)),
      expect: () => [
        WatchlistLoadedState(items: [tItem]),
      ],
    );

    blocTest<WatchlistBloc, WatchlistState>(
      'emits WatchlistLoadedState with updated item list when RemoveFromWatchlistEvent is added',
      build: () {
        when(() => mockRepository.removeFromWatchlist(1))
            .thenAnswer((_) async => const Right(null));
        when(() => mockRepository.getWatchlist())
            .thenAnswer((_) async => const Right([]));
        return watchlistBloc;
      },
      act: (bloc) => bloc.add(const RemoveFromWatchlistEvent(1)),
      expect: () => [
        const WatchlistLoadedState(
          items: [],
          lastRemovedItem: null,
          message: null,
        ),
      ],
    );

    blocTest<WatchlistBloc, WatchlistState>(
      'emits WatchlistLoadedState when ToggleWatchedEvent is added',
      build: () {
        when(() => mockRepository.toggleWatched(1, true))
            .thenAnswer((_) async => const Right(null));
        when(() => mockRepository.getWatchlist())
            .thenAnswer((_) async => Right([tItem.copyWith(daXem: true)]));
        return watchlistBloc;
      },
      act: (bloc) => bloc.add(const ToggleWatchedEvent(movieId: 1, daXem: true)),
      expect: () => [
        WatchlistLoadedState(items: [tItem.copyWith(daXem: true)]),
      ],
    );
  });
}
