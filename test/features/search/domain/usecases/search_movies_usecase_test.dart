import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/errors/failure.dart';
import 'package:movie_app/features/home/domain/repositories/movie_repository.dart';
import 'package:movie_app/features/home/models/movie.dart';
import 'package:movie_app/features/search/domain/usecases/search_movies_usecase.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late SearchMoviesUseCase useCase;
  late MockMovieRepository mockRepository;

  setUp(() {
    mockRepository = MockMovieRepository();
    useCase = SearchMoviesUseCase(mockRepository);
  });

  const tQuery = 'Lật Mặt';
  final List<Movie> tMovies = [
    Movie(
      id: 101,
      tenPhim: 'Lật Mặt 7: Một Điều Ước',
      hinhAnh: '/latmat7.jpg',
      moTa: 'Phim gia đình xúc động',
      diemDanhGia: 9.0,
    ),
  ];

  test('should call searchMovies on repository and return list of movies', () async {
    when(() => mockRepository.searchMovies(query: tQuery, page: 1))
        .thenAnswer((_) async => Right(tMovies));

    final result = await useCase(query: tQuery);

    expect(result, Right(tMovies));
    verify(() => mockRepository.searchMovies(query: tQuery, page: 1));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return ServerFailure when search fails', () async {
    when(() => mockRepository.searchMovies(query: tQuery, page: 1))
        .thenAnswer((_) async => const Left(ServerFailure('API error')));

    final result = await useCase(query: tQuery);

    expect(result, const Left(ServerFailure('API error')));
    verify(() => mockRepository.searchMovies(query: tQuery, page: 1));
    verifyNoMoreInteractions(mockRepository);
  });
}
