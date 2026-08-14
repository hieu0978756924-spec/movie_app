import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/features/home/domain/entities/video.dart';
import 'package:movie_app/features/home/domain/repositories/movie_repository.dart';
import 'package:movie_app/features/home/domain/usecases/get_movie_trailers_usecase.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late GetMovieTrailersUseCase useCase;
  late MockMovieRepository mockRepository;

  setUp(() {
    mockRepository = MockMovieRepository();
    useCase = GetMovieTrailersUseCase(mockRepository);
  });

  const tMovieId = 123;
  const tVideos = [
    Video(
      id: 'vid123',
      name: 'Official Trailer',
      key: 'dQw4w9WgXcQ',
      site: 'YouTube',
      type: 'Trailer',
      official: true,
    ),
  ];

  test('should get movie trailers from the repository', () async {
    when(() => mockRepository.getMovieTrailers(tMovieId))
        .thenAnswer((_) async => const Right(tVideos));

    final result = await useCase(tMovieId);

    expect(result, const Right(tVideos));
    verify(() => mockRepository.getMovieTrailers(tMovieId));
    verifyNoMoreInteractions(mockRepository);
  });
}
