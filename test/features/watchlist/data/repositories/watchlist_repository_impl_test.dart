import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:movie_app/features/home/models/movie.dart';
import 'package:movie_app/features/watchlist/data/datasources/watchlist_local_datasource.dart';
import 'package:movie_app/features/watchlist/data/datasources/watchlist_remote_datasource.dart';
import 'package:movie_app/features/watchlist/data/models/watchlist_item_model.dart';
import 'package:movie_app/features/watchlist/data/repositories/watchlist_repository_impl.dart';

class MockWatchlistLocalDataSource extends Mock
    implements WatchlistLocalDataSource {}

class MockWatchlistRemoteDataSource extends Mock
    implements WatchlistRemoteDataSource {}

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

void main() {
  late MockWatchlistLocalDataSource mockLocalDataSource;
  late MockWatchlistRemoteDataSource mockRemoteDataSource;
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;
  late WatchlistRepositoryImpl repository;

  setUp(() {
    mockLocalDataSource = MockWatchlistLocalDataSource();
    mockRemoteDataSource = MockWatchlistRemoteDataSource();
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();

    when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
    when(() => mockGoTrueClient.currentUser).thenReturn(null);

    repository = WatchlistRepositoryImpl(
      mockLocalDataSource,
      mockRemoteDataSource,
      mockSupabaseClient,
    );

    registerFallbackValue(
      const WatchlistItemModel(
        id: 1,
        tenPhim: 'Test',
        hinhAnh: 'poster.jpg',
        diemDanhGia: 8.5,
        addedAt: '2026-08-07T10:00:00.000',
      ),
    );
  });

  const tModel = WatchlistItemModel(
    id: 1,
    tenPhim: 'Inception',
    hinhAnh: '/inception.jpg',
    backdropPath: '/inception_bg.jpg',
    diemDanhGia: 8.8,
    theLoai: 'Sci-Fi',
    namPhatHanh: 2010,
    daXem: false,
    addedAt: '2026-08-07T10:00:00.000',
  );

  final tMovie = Movie(
    id: 1,
    tenPhim: 'Inception',
    hinhAnh: '/inception.jpg',
    backdropPath: '/inception_bg.jpg',
    diemDanhGia: 8.8,
    theLoai: 'Sci-Fi',
    namPhatHanh: 2010,
    moTa: 'Dream movie',
  );

  group('WatchlistRepositoryImpl Tests', () {
    test(
        'getWatchlist returns Right(List<WatchlistItem>) when local source succeeds',
        () async {
      when(() => mockLocalDataSource.getWatchlist())
          .thenAnswer((_) async => [tModel]);

      final result = await repository.getWatchlist();

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Should be Right'),
        (items) {
          expect(items.length, equals(1));
          expect(items.first.id, equals(1));
          expect(items.first.tenPhim, equals('Inception'));
          expect(items.first.daXem, isFalse);
        },
      );
    });

    test(
        'addToWatchlist calls localDataSource.addToWatchlist and returns Right',
        () async {
      when(() => mockLocalDataSource.addToWatchlist(any()))
          .thenAnswer((_) async {});

      final result = await repository.addToWatchlist(tMovie);

      expect(result.isRight(), isTrue);
      verify(() => mockLocalDataSource.addToWatchlist(any())).called(1);
    });

    test(
        'removeFromWatchlist calls localDataSource.removeFromWatchlist and returns Right',
        () async {
      when(() => mockLocalDataSource.removeFromWatchlist(1))
          .thenAnswer((_) async {});

      final result = await repository.removeFromWatchlist(1);

      expect(result.isRight(), isTrue);
      verify(() => mockLocalDataSource.removeFromWatchlist(1)).called(1);
    });

    test('toggleWatched calls localDataSource.toggleWatched and returns Right',
        () async {
      when(() => mockLocalDataSource.toggleWatched(1, true))
          .thenAnswer((_) async {});

      final result = await repository.toggleWatched(1, true);

      expect(result.isRight(), isTrue);
      verify(() => mockLocalDataSource.toggleWatched(1, true)).called(1);
    });

    test('syncWatchlist returns Right(null) when user is not logged in',
        () async {
      final result = await repository.syncWatchlist();
      expect(result.isRight(), isTrue);
    });

    test('syncWatchlist performs bidirectional merge when user is logged in',
        () async {
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('user_123');
      when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);

      when(() => mockLocalDataSource.getWatchlist())
          .thenAnswer((_) async => [tModel]);
      when(() => mockRemoteDataSource.getRemoteWatchlist('user_123'))
          .thenAnswer((_) async => []);
      when(() => mockRemoteDataSource.upsertRemoteWatchlist('user_123', any()))
          .thenAnswer((_) async {});

      final result = await repository.syncWatchlist();

      expect(result.isRight(), isTrue);
      verify(() =>
              mockRemoteDataSource.upsertRemoteWatchlist('user_123', tModel))
          .called(1);
    });
  });
}
