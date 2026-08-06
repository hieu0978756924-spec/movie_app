import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/features/home/domain/repositories/movie_repository.dart';
import 'package:movie_app/features/home/domain/usecases/get_similar_movies_usecase.dart';
import 'package:movie_app/features/home/models/movie.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late GetSimilarMoviesUseCase useCase;
  late MockMovieRepository mockRepository;

  setUp(() {
    mockRepository = MockMovieRepository();
    useCase = GetSimilarMoviesUseCase(mockRepository);
  });

  const tMovieId = 123;
  final List<Movie> tMovies = [
    Movie(
      id: 456,
      tenPhim: 'Similar Movie Test',
      hinhAnh: '/poster.jpg',
      moTa: 'Overview',
      diemDanhGia: 8.5,
    ),
  ];

  test('should get similar movies from the repository', () async {
    when(() => mockRepository.getSimilarMovies(tMovieId))
        .thenAnswer((_) async => Right(tMovies));

    final result = await useCase(tMovieId);

    expect(result, Right(tMovies));
    verify(() => mockRepository.getSimilarMovies(tMovieId));
    verifyNoMoreInteractions(mockRepository);
  });
}
