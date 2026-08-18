// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:go_router/go_router.dart' as _i583;
import 'package:injectable/injectable.dart' as _i526;
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;

import '../../features/auth/data/datasources/auth_remote_datasource.dart'
    as _i161;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/get_current_user_usecase.dart'
    as _i17;
import '../../features/auth/domain/usecases/login_usecase.dart' as _i188;
import '../../features/auth/domain/usecases/register_usecase.dart' as _i941;
import '../../features/auth/domain/usecases/reset_password_usecase.dart'
    as _i474;
import '../../features/auth/presentation/bloc/auth_bloc.dart' as _i797;
import '../../features/home/data/datasources/movie_remote_datasource.dart'
    as _i514;
import '../../features/home/data/repositories/movie_repository_impl.dart'
    as _i449;
import '../../features/home/domain/repositories/movie_repository.dart'
    as _i1023;
import '../../features/home/domain/usecases/get_movie_credits_usecase.dart'
    as _i288;
import '../../features/home/domain/usecases/get_movie_detail_usecase.dart'
    as _i978;
import '../../features/home/domain/usecases/get_movie_trailers_usecase.dart'
    as _i989;
import '../../features/home/domain/usecases/get_now_playing_movies_usecase.dart'
    as _i233;
import '../../features/home/domain/usecases/get_popular_movies_usecase.dart'
    as _i560;
import '../../features/home/domain/usecases/get_similar_movies_usecase.dart'
    as _i639;
import '../../features/home/domain/usecases/get_top_rated_movies_usecase.dart'
    as _i639;
import '../../features/home/domain/usecases/get_trending_movies_usecase.dart'
    as _i858;
import '../../features/home/domain/usecases/get_upcoming_movies_usecase.dart'
    as _i749;
import '../../features/home/presentation/bloc/category_bloc.dart' as _i311;
import '../../features/home/presentation/bloc/home_bloc.dart' as _i202;
import '../../features/home/presentation/bloc/movie_detail_bloc.dart' as _i379;
import '../../features/review/data/datasources/review_remote_datasource.dart'
    as _i602;
import '../../features/review/data/repositories/review_repository_impl.dart'
    as _i645;
import '../../features/review/domain/repositories/review_repository.dart'
    as _i364;
import '../../features/review/presentation/bloc/review_bloc.dart' as _i610;
import '../../features/search/domain/usecases/discover_movies_usecase.dart'
    as _i992;
import '../../features/search/domain/usecases/get_genres_usecase.dart' as _i226;
import '../../features/search/domain/usecases/search_movies_usecase.dart'
    as _i451;
import '../../features/search/presentation/bloc/search_bloc.dart' as _i552;
import '../../features/watchlist/data/datasources/watchlist_local_datasource.dart'
    as _i105;
import '../../features/watchlist/data/datasources/watchlist_remote_datasource.dart'
    as _i205;
import '../../features/watchlist/data/repositories/watchlist_repository_impl.dart'
    as _i967;
import '../../features/watchlist/domain/repositories/watchlist_repository.dart'
    as _i974;
import '../../features/watchlist/presentation/bloc/watchlist_bloc.dart'
    as _i767;
import '../localization/language_cubit.dart' as _i170;
import '../network/dio_client.dart' as _i667;
import '../network/supabase_client.dart' as _i650;
import '../router/router_module.dart' as _i948;
import '../services/local_json_service.dart' as _i259;
import '../theme/theme_cubit.dart' as _i611;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final networkModule = _$NetworkModule();
    final supabaseModule = _$SupabaseModule();
    final routerModule = _$RouterModule();
    gh.singleton<_i170.LanguageCubit>(() => _i170.LanguageCubit());
    gh.singleton<_i361.Dio>(() => networkModule.dio);
    gh.singleton<_i454.SupabaseClient>(() => supabaseModule.supabase);
    gh.singleton<_i583.GoRouter>(() => routerModule.router);
    gh.lazySingleton<_i259.LocalJsonService>(() => _i259.LocalJsonService());
    gh.lazySingleton<_i611.ThemeCubit>(() => _i611.ThemeCubit());
    gh.lazySingleton<_i205.WatchlistRemoteDataSource>(
        () => _i205.WatchlistRemoteDataSourceImpl(gh<_i454.SupabaseClient>()));
    gh.lazySingleton<_i161.AuthRemoteDataSource>(
        () => _i161.AuthRemoteDataSourceImpl(gh<_i454.SupabaseClient>()));
    gh.lazySingleton<_i787.AuthRepository>(
        () => _i153.AuthRepositoryImpl(gh<_i161.AuthRemoteDataSource>()));
    gh.lazySingleton<_i514.MovieRemoteDataSource>(
        () => _i514.MovieRemoteDataSourceImpl(gh<_i361.Dio>()));
    gh.lazySingleton<_i105.WatchlistLocalDataSource>(
        () => _i105.WatchlistLocalDataSourceImpl());
    gh.lazySingleton<_i974.WatchlistRepository>(
        () => _i967.WatchlistRepositoryImpl(
              gh<_i105.WatchlistLocalDataSource>(),
              gh<_i205.WatchlistRemoteDataSource>(),
              gh<_i454.SupabaseClient>(),
            ));
    gh.lazySingleton<_i602.ReviewRemoteDataSource>(
        () => _i602.ReviewRemoteDataSourceImpl(
              gh<_i361.Dio>(),
              gh<_i454.SupabaseClient>(),
            ));
    gh.lazySingleton<_i1023.MovieRepository>(
        () => _i449.MovieRepositoryImpl(gh<_i514.MovieRemoteDataSource>()));
    gh.lazySingleton<_i17.GetCurrentUserUseCase>(
        () => _i17.GetCurrentUserUseCase(gh<_i787.AuthRepository>()));
    gh.lazySingleton<_i188.LoginUseCase>(
        () => _i188.LoginUseCase(gh<_i787.AuthRepository>()));
    gh.lazySingleton<_i941.RegisterUseCase>(
        () => _i941.RegisterUseCase(gh<_i787.AuthRepository>()));
    gh.lazySingleton<_i474.ResetPasswordUseCase>(
        () => _i474.ResetPasswordUseCase(gh<_i787.AuthRepository>()));
    gh.factory<_i767.WatchlistBloc>(
        () => _i767.WatchlistBloc(gh<_i974.WatchlistRepository>()));
    gh.lazySingleton<_i364.ReviewRepository>(
        () => _i645.ReviewRepositoryImpl(gh<_i602.ReviewRemoteDataSource>()));
    gh.lazySingleton<_i288.GetMovieCreditsUseCase>(
        () => _i288.GetMovieCreditsUseCase(gh<_i1023.MovieRepository>()));
    gh.lazySingleton<_i978.GetMovieDetailUseCase>(
        () => _i978.GetMovieDetailUseCase(gh<_i1023.MovieRepository>()));
    gh.lazySingleton<_i989.GetMovieTrailersUseCase>(
        () => _i989.GetMovieTrailersUseCase(gh<_i1023.MovieRepository>()));
    gh.lazySingleton<_i233.GetNowPlayingMoviesUseCase>(
        () => _i233.GetNowPlayingMoviesUseCase(gh<_i1023.MovieRepository>()));
    gh.lazySingleton<_i560.GetPopularMoviesUseCase>(
        () => _i560.GetPopularMoviesUseCase(gh<_i1023.MovieRepository>()));
    gh.lazySingleton<_i639.GetSimilarMoviesUseCase>(
        () => _i639.GetSimilarMoviesUseCase(gh<_i1023.MovieRepository>()));
    gh.lazySingleton<_i639.GetTopRatedMoviesUseCase>(
        () => _i639.GetTopRatedMoviesUseCase(gh<_i1023.MovieRepository>()));
    gh.lazySingleton<_i858.GetTrendingMoviesUseCase>(
        () => _i858.GetTrendingMoviesUseCase(gh<_i1023.MovieRepository>()));
    gh.lazySingleton<_i749.GetUpcomingMoviesUseCase>(
        () => _i749.GetUpcomingMoviesUseCase(gh<_i1023.MovieRepository>()));
    gh.lazySingleton<_i992.DiscoverMoviesUseCase>(
        () => _i992.DiscoverMoviesUseCase(gh<_i1023.MovieRepository>()));
    gh.lazySingleton<_i226.GetGenresUseCase>(
        () => _i226.GetGenresUseCase(gh<_i1023.MovieRepository>()));
    gh.lazySingleton<_i451.SearchMoviesUseCase>(
        () => _i451.SearchMoviesUseCase(gh<_i1023.MovieRepository>()));
    gh.factory<_i610.ReviewBloc>(
        () => _i610.ReviewBloc(gh<_i364.ReviewRepository>()));
    gh.factory<_i797.AuthBloc>(() => _i797.AuthBloc(
          gh<_i188.LoginUseCase>(),
          gh<_i941.RegisterUseCase>(),
          gh<_i474.ResetPasswordUseCase>(),
          gh<_i17.GetCurrentUserUseCase>(),
        ));
    gh.factory<_i202.HomeBloc>(() => _i202.HomeBloc(
          gh<_i858.GetTrendingMoviesUseCase>(),
          gh<_i233.GetNowPlayingMoviesUseCase>(),
          gh<_i560.GetPopularMoviesUseCase>(),
          gh<_i639.GetTopRatedMoviesUseCase>(),
          gh<_i749.GetUpcomingMoviesUseCase>(),
          gh<_i639.GetSimilarMoviesUseCase>(),
          gh<_i105.WatchlistLocalDataSource>(),
        ));
    gh.factory<_i552.SearchBloc>(() => _i552.SearchBloc(
          gh<_i451.SearchMoviesUseCase>(),
          gh<_i226.GetGenresUseCase>(),
          gh<_i992.DiscoverMoviesUseCase>(),
        ));
    gh.factory<_i311.CategoryBloc>(() => _i311.CategoryBloc(
          gh<_i858.GetTrendingMoviesUseCase>(),
          gh<_i233.GetNowPlayingMoviesUseCase>(),
          gh<_i560.GetPopularMoviesUseCase>(),
          gh<_i639.GetTopRatedMoviesUseCase>(),
          gh<_i749.GetUpcomingMoviesUseCase>(),
        ));
    gh.factory<_i379.MovieDetailBloc>(() => _i379.MovieDetailBloc(
          gh<_i978.GetMovieDetailUseCase>(),
          gh<_i288.GetMovieCreditsUseCase>(),
          gh<_i989.GetMovieTrailersUseCase>(),
          gh<_i639.GetSimilarMoviesUseCase>(),
          gh<_i974.WatchlistRepository>(),
        ));
    return this;
  }
}

class _$NetworkModule extends _i667.NetworkModule {}

class _$SupabaseModule extends _i650.SupabaseModule {}

class _$RouterModule extends _i948.RouterModule {}
