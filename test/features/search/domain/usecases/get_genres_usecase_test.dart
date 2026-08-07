import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/errors/failure.dart';
import 'package:movie_app/features/home/domain/entities/genre.dart';
import 'package:movie_app/features/home/domain/repositories/movie_repository.dart';
import 'package:movie_app/features/search/domain/usecases/get_genres_usecase.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late GetGenresUseCase useCase;
  late MockMovieRepository mockRepository;

  setUp(() {
    mockRepository = MockMovieRepository();
    useCase = GetGenresUseCase(mockRepository);
  });

  final List<Genre> tGenres = [
    const Genre(id: 28, name: 'Hành động'),
    const Genre(id: 35, name: 'Hài'),
  ];

  test('should call getGenres on repository and return list of genres', () async {
    when(() => mockRepository.getGenres())
        .thenAnswer((_) async => Right(tGenres));

    final result = await useCase();

    expect(result, Right(tGenres));
    verify(() => mockRepository.getGenres());
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return ServerFailure when getGenres fails', () async {
    when(() => mockRepository.getGenres())
        .thenAnswer((_) async => const Left(ServerFailure('API error')));

    final result = await useCase();

    expect(result, const Left(ServerFailure('API error')));
    verify(() => mockRepository.getGenres());
    verifyNoMoreInteractions(mockRepository);
  });
}
