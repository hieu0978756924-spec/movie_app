import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:movie_app/features/watchlist/data/datasources/watchlist_remote_datasource.dart';
import 'package:movie_app/features/watchlist/data/models/watchlist_item_model.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

void main() {
  late MockSupabaseClient mockSupabaseClient;
  late WatchlistRemoteDataSourceImpl dataSource;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    dataSource = WatchlistRemoteDataSourceImpl(mockSupabaseClient);
  });

  const tItem = WatchlistItemModel(
    id: 1,
    tenPhim: 'Test Movie',
    hinhAnh: '/poster.jpg',
    backdropPath: '/backdrop.jpg',
    diemDanhGia: 8.5,
    theLoai: 'Action',
    namPhatHanh: 2026,
    daXem: true,
    addedAt: '2026-08-07T10:00:00.000',
  );

  group('WatchlistRemoteDataSourceImpl Tests', () {
    test('instantiates successfully with SupabaseClient', () {
      expect(dataSource.supabaseClient, equals(mockSupabaseClient));
    });

    test('tItem serialization mapping test', () {
      final map = tItem.toMap();
      expect(map['id'], equals(1));
      expect(map['tenPhim'], equals('Test Movie'));
      expect(map['daXem'], isTrue);
    });
  });
}
