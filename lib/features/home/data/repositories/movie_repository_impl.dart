import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/youtube_utils.dart';
import '../../controllers/home_controller.dart';
import '../../domain/entities/cast.dart';
import '../../domain/entities/genre.dart';
import '../../domain/entities/video.dart';
import '../../domain/repositories/movie_repository.dart';
import '../../models/movie.dart';
import '../datasources/movie_remote_datasource.dart';
import '../models/movie_response_model.dart';

@LazySingleton(as: MovieRepository)
class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource remoteDataSource;

  MovieRepositoryImpl(this.remoteDataSource);

  Future<void> _ensureInitialized() async {
    await HomeController.instance.init();
  }

  Future<Either<Failure, List<Movie>>> _fetchFromRemoteOrLocal({
    required Future<MovieResponseModel> Function() remoteCall,
    required List<Movie> fallbackList,
    int page = 1,
  }) async {
    await _ensureInitialized();
    try {
      final response = await remoteCall();
      final remoteMovies = response.results.map((m) => m.toEntity()).toList();
      if (remoteMovies.isNotEmpty) {
        return Right(remoteMovies);
      }
    } catch (_) {}

    // Local JSON Fallback pagination logic (no duplicate looping)
    if (page == 1) {
      return Right(fallbackList);
    }

    final allLocal = HomeController.instance.danhSachPhim;
    final shownIds = fallbackList.map((m) => m.id).toSet();
    final remaining = allLocal.where((m) => !shownIds.contains(m.id)).toList();

    if (page == 2 && remaining.isNotEmpty) {
      return Right(remaining);
    }

    return const Right([]);
  }

  @override
  Future<Either<Failure, List<Movie>>> getTrendingMovies(
      {int page = 1}) async {
    return _fetchFromRemoteOrLocal(
      remoteCall: () => remoteDataSource.getTrendingMovies(page: page),
      fallbackList: HomeController.instance.danhSachPhimHot,
      page: page,
    );
  }

  @override
  Future<Either<Failure, List<Movie>>> getNowPlayingMovies(
      {int page = 1}) async {
    return _fetchFromRemoteOrLocal(
      remoteCall: () => remoteDataSource.getNowPlayingMovies(page: page),
      fallbackList: HomeController.instance.danhSachPhimDangChieu,
      page: page,
    );
  }

  @override
  Future<Either<Failure, List<Movie>>> getPopularMovies(
      {int page = 1}) async {
    return _fetchFromRemoteOrLocal(
      remoteCall: () => remoteDataSource.getPopularMovies(page: page),
      fallbackList: HomeController.instance.danhSachPhimPhoBien,
      page: page,
    );
  }

  @override
  Future<Either<Failure, List<Movie>>> getTopRatedMovies(
      {int page = 1}) async {
    return _fetchFromRemoteOrLocal(
      remoteCall: () => remoteDataSource.getTopRatedMovies(page: page),
      fallbackList: HomeController.instance.danhSachPhimDanhGiaCao,
      page: page,
    );
  }

  @override
  Future<Either<Failure, List<Movie>>> getUpcomingMovies(
      {int page = 1}) async {
    return _fetchFromRemoteOrLocal(
      remoteCall: () => remoteDataSource.getUpcomingMovies(page: page),
      fallbackList: HomeController.instance.danhSachPhimSapChieu,
      page: page,
    );
  }

  @override
  Future<Either<Failure, Movie>> getMovieDetail(int movieId) async {
    await _ensureInitialized();
    final realTmdbId = YoutubeUtils.getRealTmdbId(movieId);
    try {
      final detailModel = await remoteDataSource.getMovieDetail(realTmdbId);
      final entity = detailModel.toEntity();
      return Right(movieId != realTmdbId ? entity.copyWith(id: movieId) : entity);
    } catch (_) {}

    try {
      final movie = HomeController.instance.danhSachPhim.firstWhere(
        (m) => m.id == movieId || (movieId <= 10 && m.id == realTmdbId),
      );
      return Right(movie);
    } catch (_) {
      return const Left(ServerFailure('Không tìm thấy phim'));
    }
  }

  @override
  Future<Either<Failure, List<Cast>>> getMovieCredits(int movieId) async {
    await _ensureInitialized();
    final realTmdbId = YoutubeUtils.getRealTmdbId(movieId);
    try {
      final response = await remoteDataSource.getMovieCredits(realTmdbId);
      final castList = response.cast.map((model) => model.toEntity()).toList();
      if (castList.isNotEmpty) return Right(castList);
    } catch (_) {}

    final movieResult = await getMovieDetail(movieId);
    return movieResult.fold(
      (failure) => Right(_getFallbackCastList(movieId)),
      (movie) {
        if (movie.cast.isNotEmpty) {
          final castList = movie.cast.map((c) {
            final actor = HomeController.instance.getActorById(c.actorId);
            return Cast(
              id: c.actorId,
              name: actor?.name ?? 'Diễn viên',
              character: c.characterName,
              profilePath: actor?.profilePath ?? 'assets/images/actor_1.jpg',
            );
          }).toList();
          return Right(castList);
        }
        return Right(_getFallbackCastList(movieId));
      },
    );
  }

  List<Cast> _getFallbackCastList(int movieId) {
    return const [
      Cast(
        id: 101,
        name: 'Timothée Chalamet',
        character: 'Paul Atreides',
        profilePath: 'assets/images/actor_1.jpg',
      ),
      Cast(
        id: 102,
        name: 'Zendaya',
        character: 'Chani',
        profilePath: 'assets/images/actor_2.jpg',
      ),
    ];
  }

  @override
  Future<Either<Failure, List<Video>>> getMovieTrailers(int movieId) async {
    await _ensureInitialized();
    final realTmdbId = YoutubeUtils.getRealTmdbId(movieId);
    try {
      final response = await remoteDataSource.getMovieTrailers(realTmdbId);
      final trailers = response.results.map((model) => model.toEntity()).toList();
      final validTrailers = trailers
          .where((v) => v.site.toLowerCase() == 'youtube' && v.key.trim().isNotEmpty)
          .toList();
      if (validTrailers.isNotEmpty) return Right(validTrailers);
    } catch (_) {}

    final movieResult = await getMovieDetail(movieId);
    Movie? movie;
    movieResult.fold((_) {}, (m) => movie = m);

    if (movie == null) {
      return Right([_buildDefaultVideo(movieId)]);
    }

    final titleToSearch = movie!.originalTitle.isNotEmpty
        ? movie!.originalTitle
        : movie!.tenPhim;

    if (titleToSearch.isNotEmpty) {
      try {
        final searchModel = await remoteDataSource.searchMovies(query: titleToSearch);
        if (searchModel.results.isNotEmpty) {
          final tmdbId = searchModel.results.first.id;
          final tmdbTrailersResp = await remoteDataSource.getMovieTrailers(tmdbId);
          final tmdbTrailers = tmdbTrailersResp.results
              .map((m) => m.toEntity())
              .where((v) => v.site.toLowerCase() == 'youtube' && v.key.trim().isNotEmpty)
              .toList();
          if (tmdbTrailers.isNotEmpty) {
            return Right(tmdbTrailers);
          }
        }
      } catch (_) {}
    }

    final keyFromMovieUrl = YoutubeUtils.extractYoutubeKey(movie!.trailerUrl);
    final key = keyFromMovieUrl.isNotEmpty
        ? keyFromMovieUrl
        : YoutubeUtils.getFallbackTrailerKeyForMovieId(movieId);

    return Right([
      Video(
        id: 'vid_$movieId',
        name: '${movie!.tenPhim} Official Trailer',
        key: key,
        site: 'YouTube',
        type: 'Trailer',
        official: true,
      ),
    ]);
  }

  Video _buildDefaultVideo(int movieId) {
    final key = YoutubeUtils.getFallbackTrailerKeyForMovieId(movieId);
    return Video(
      id: 'fallback_$movieId',
      name: 'Trailer Phim',
      key: key,
      site: 'YouTube',
      type: 'Trailer',
      official: true,
    );
  }

  @override
  Future<Either<Failure, List<Movie>>> getSimilarMovies(int movieId) async {
    await _ensureInitialized();
    try {
      final response = await remoteDataSource.getSimilarMovies(movieId);
      final movies = response.results.map((model) => model.toEntity()).toList();
      if (movies.isNotEmpty) return Right(movies);
    } catch (_) {}

    return Right(HomeController.instance.danhSachPhim
        .where((m) => m.id != movieId)
        .take(5)
        .toList());
  }

  @override
  Future<Either<Failure, List<Movie>>> searchMovies(
      {required String query, int page = 1}) async {
    await _ensureInitialized();
    try {
      final response = await remoteDataSource.searchMovies(query: query, page: page);
      final movies = response.results.map((model) => model.toEntity()).toList();
      if (movies.isNotEmpty) return Right(movies);
    } catch (_) {}

    return Right(HomeController.instance.timKiemPhim(query));
  }

  @override
  Future<Either<Failure, List<Genre>>> getGenres() async {
    try {
      final response = await remoteDataSource.getGenres();
      final genres = response.genres.map((model) => model.toEntity()).toList();
      if (genres.isNotEmpty) return Right(genres);
    } catch (_) {}

    return const Right([
      Genre(id: 1, name: 'Tất cả'),
      Genre(id: 2, name: 'Hành động'),
      Genre(id: 3, name: 'Phiêu lưu'),
      Genre(id: 4, name: 'Khoa học viễn tưởng'),
      Genre(id: 5, name: 'Hoạt hình'),
      Genre(id: 6, name: 'Hài hước'),
      Genre(id: 7, name: 'Tiểu sử'),
      Genre(id: 8, name: 'Chính kịch'),
    ]);
  }

  @override
  Future<Either<Failure, List<Movie>>> discoverMovies({
    List<int>? withGenres,
    int? primaryReleaseYearGte,
    int? primaryReleaseYearLte,
    double? minRating,
    String? sortBy,
    int page = 1,
  }) async {
    await _ensureInitialized();
    try {
      final response = await remoteDataSource.discoverMovies(
        withGenres: withGenres,
        primaryReleaseYearGte: primaryReleaseYearGte,
        primaryReleaseYearLte: primaryReleaseYearLte,
        minRating: minRating,
        sortBy: sortBy,
        page: page,
      );
      final movies = response.results.map((model) => model.toEntity()).toList();
      if (movies.isNotEmpty) return Right(movies);
    } catch (_) {}

    return Right(HomeController.instance.danhSachPhim);
  }
}
