# Góc Phim — Technical Architecture

> **Version:** 1.0 | **Date:** 2026-08-04 | **Stack:** Flutter + BLoC + Supabase + TMDB

---

## 1. Architecture Overview

Góc Phim áp dụng **Clean Architecture** chia làm 3 tầng rõ ràng, kết hợp **BLoC pattern** cho state management.

```
┌─────────────────────────────────────────────────────┐
│                  PRESENTATION                        │
│   Pages (UI) ←→ BLoC (State) ←→ Events/States      │
├─────────────────────────────────────────────────────┤
│                    DOMAIN                            │
│   Entities │ Use Cases │ Repository Interfaces       │
├─────────────────────────────────────────────────────┤
│                     DATA                             │
│   Repository Impl │ Remote DS │ Local DS │ Models    │
└─────────────────────────────────────────────────────┘
         ↕                    ↕
   Supabase Backend      TMDB API
```

### Nguyên tắc
- **Dependency Rule**: tầng trong không biết tầng ngoài (Domain không biết Data/Presentation)
- **Entities thuần Dart**: không phụ thuộc framework
- **Repository Pattern**: Domain định nghĩa interface, Data implement
- **Either<Failure, T>**: mọi lỗi đều được type-safe

---

## 2. Folder Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart      # App-wide constants
│   │   ├── api_constants.dart      # TMDB base URL, image URL
│   │   └── supabase_constants.dart # Table names, column names
│   ├── di/
│   │   ├── injection.dart          # get_it setup (main entry)
│   │   └── injection.config.dart   # auto-generated bởi injectable
│   ├── errors/
│   │   ├── failure.dart            # abstract Failure + subtypes
│   │   └── exceptions.dart         # ServerException, NetworkException...
│   ├── network/
│   │   ├── dio_client.dart         # Dio singleton + base options
│   │   ├── auth_interceptor.dart   # Inject TMDB API key vào header
│   │   └── error_interceptor.dart  # Parse lỗi HTTP → Failure
│   ├── router/
│   │   ├── app_router.dart         # GoRouter config
│   │   └── route_names.dart        # Named route constants
│   ├── theme/
│   │   ├── app_theme.dart          # ThemeData dark/light
│   │   ├── app_colors.dart         # Color palette
│   │   └── app_typography.dart     # TextStyle definitions
│   └── utils/
│       ├── date_utils.dart
│       └── image_url_helper.dart   # Build TMDB image URL
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── auth_remote_datasource.dart   # Supabase Auth calls
│   │   │   ├── models/
│   │   │   │   └── user_model.dart               # JSON ↔ UserEntity
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart          # abstract interface
│   │   │   └── usecases/
│   │   │       ├── login_usecase.dart
│   │   │       ├── register_usecase.dart
│   │   │       ├── logout_usecase.dart
│   │   │       └── get_current_user_usecase.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── auth_bloc.dart
│   │       │   ├── auth_event.dart
│   │       │   └── auth_state.dart
│   │       └── pages/
│   │           ├── login_page.dart
│   │           ├── register_page.dart
│   │           └── forgot_password_page.dart
│   │
│   ├── home/
│   │   ├── data/ ...
│   │   ├── domain/
│   │   │   └── usecases/
│   │   │       ├── get_trending_movies_usecase.dart
│   │   │       ├── get_now_playing_usecase.dart
│   │   │       ├── get_popular_movies_usecase.dart
│   │   │       └── get_genres_usecase.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── home_bloc.dart
│   │       │   ├── home_event.dart
│   │       │   └── home_state.dart
│   │       └── pages/
│   │           └── home_page.dart
│   │
│   ├── movie_detail/
│   │   ├── domain/
│   │   │   └── usecases/
│   │   │       ├── get_movie_detail_usecase.dart
│   │   │       ├── get_movie_trailer_usecase.dart
│   │   │       ├── get_movie_credits_usecase.dart
│   │   │       └── get_similar_movies_usecase.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   └── movie_detail_bloc.dart
│   │       └── pages/
│   │           └── movie_detail_page.dart
│   │
│   ├── search/
│   │   ├── domain/
│   │   │   └── usecases/
│   │   │       └── search_movies_usecase.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   └── search_bloc.dart  # debounce EventTransformer
│   │       └── pages/
│   │           └── search_page.dart
│   │
│   ├── watchlist/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── watchlist_local_datasource.dart  # Hive
│   │   │   │   └── watchlist_remote_datasource.dart # Supabase
│   │   │   └── repositories/
│   │   │       └── watchlist_repository_impl.dart   # offline-first
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   └── watchlist_bloc.dart
│   │       └── pages/
│   │           └── watchlist_page.dart
│   │
│   ├── review/
│   │   ├── data/
│   │   │   └── datasources/
│   │   │       └── review_remote_datasource.dart    # Supabase
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   └── review_bloc.dart
│   │       └── widgets/
│   │           ├── review_list_widget.dart
│   │           └── write_review_sheet.dart
│   │
│   └── profile/
│       └── presentation/
│           ├── bloc/
│           │   └── profile_bloc.dart
│           └── pages/
│               └── profile_page.dart
│
└── shared/
    ├── widgets/
    │   ├── movie_card.dart           # Reusable card với poster
    │   ├── section_header.dart
    │   ├── shimmer_loading.dart
    │   ├── error_widget.dart
    │   └── empty_state_widget.dart
    └── extensions/
        ├── context_extension.dart    # theme, navigator shortcuts
        └── string_extension.dart
```

---

## 3. BLoC Pattern

### Convention chuẩn cho mỗi feature:

```dart
// event.dart — sealed class (Dart 3)
sealed class HomeEvent {}
class HomeFetchRequested extends HomeEvent {}
class HomeRefreshRequested extends HomeEvent {}

// state.dart — dùng Equatable
class HomeState extends Equatable {
  final HomeStatus status;          // initial / loading / success / failure
  final List<MovieEntity> trending;
  final List<MovieEntity> nowPlaying;
  final String? errorMessage;

  const HomeState({...});

  HomeState copyWith({...}) => HomeState(...);

  @override
  List<Object?> get props => [status, trending, nowPlaying, errorMessage];
}

// bloc.dart
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({required this.getTrending, required this.getNowPlaying})
    : super(HomeState.initial()) {
    on<HomeFetchRequested>(_onFetch);
  }

  Future<void> _onFetch(HomeFetchRequested event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading));
    final result = await getTrending(NoParams());
    result.fold(
      (failure) => emit(state.copyWith(status: HomeStatus.failure, errorMessage: failure.message)),
      (movies) => emit(state.copyWith(status: HomeStatus.success, trending: movies)),
    );
  }
}
```

### Search BLoC với Debounce:
```dart
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc(...) : super(SearchState.initial()) {
    on<SearchQueryChanged>(
      _onQueryChanged,
      transformer: debounce(const Duration(milliseconds: 500)),
    );
  }
}

// EventTransformer helper
EventTransformer<T> debounce<T>(Duration duration) =>
  (events, mapper) => events.debounceTime(duration).switchMap(mapper);
```

---

## 4. Data Layer — API Integration

### 4.1 TMDB API Client (Dio)
```dart
// api_constants.dart
const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p/';
const String tmdbApiKey = String.fromEnvironment('TMDB_API_KEY');

// dio_client.dart
Dio createDioClient() => Dio(BaseOptions(
  baseUrl: tmdbBaseUrl,
  connectTimeout: const Duration(seconds: 10),
  queryParameters: {'api_key': tmdbApiKey, 'language': 'vi-VN'},
));
```

### 4.2 TMDB Endpoints

| UseCase | Method | Endpoint |
|---------|--------|----------|
| GetTrending | GET | `/trending/movie/week` |
| GetNowPlaying | GET | `/movie/now_playing` |
| GetPopular | GET | `/movie/popular` |
| GetTopRated | GET | `/movie/top_rated` |
| GetMovieDetail | GET | `/movie/{id}` |
| GetMovieCredits | GET | `/movie/{id}/credits` |
| GetMovieVideos | GET | `/movie/{id}/videos` |
| GetSimilarMovies | GET | `/movie/{id}/similar` |
| SearchMovies | GET | `/search/movie?query={q}` |
| GetGenres | GET | `/genre/movie/list` |
| GetMoviesByGenre | GET | `/discover/movie?with_genres={id}` |

### 4.3 Supabase Setup

```dart
// main.dart
await Supabase.initialize(
  url: const String.fromEnvironment('SUPABASE_URL'),
  anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
);
```

---

## 5. Supabase Database Schema

### Table: `profiles`
```sql
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text,
  avatar_url text,
  created_at timestamptz default now()
);

-- RLS
alter table profiles enable row level security;
create policy "Users can view own profile" on profiles for select using (auth.uid() = id);
create policy "Users can update own profile" on profiles for update using (auth.uid() = id);
```

### Table: `watchlist`
```sql
create table watchlist (
  id bigserial primary key,
  user_id uuid references auth.users(id) on delete cascade,
  movie_id integer not null,
  movie_title text not null,
  poster_path text,
  watched boolean default false,
  added_at timestamptz default now(),
  unique(user_id, movie_id)
);

alter table watchlist enable row level security;
create policy "Users manage own watchlist" on watchlist
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
```

### Table: `reviews`
```sql
create table reviews (
  id bigserial primary key,
  user_id uuid references auth.users(id) on delete cascade,
  movie_id integer not null,
  rating numeric(3,1) check (rating >= 1 and rating <= 10),
  content text,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique(user_id, movie_id)
);

alter table reviews enable row level security;
create policy "Anyone can read reviews" on reviews for select using (true);
create policy "Users manage own reviews" on reviews
  for all using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
```

---

## 6. Navigation (GoRouter)

```dart
// route_names.dart
abstract class RouteName {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const home = '/';
  static const movieDetail = '/movie/:id';
  static const search = '/search';
  static const watchlist = '/watchlist';
  static const profile = '/profile';
}

// app_router.dart
final appRouter = GoRouter(
  initialLocation: RouteName.splash,
  redirect: (context, state) {
    final isLoggedIn = context.read<AuthBloc>().state is AuthAuthenticated;
    final isAuthRoute = [RouteName.login, RouteName.register].contains(state.matchedLocation);
    if (!isLoggedIn && !isAuthRoute) return RouteName.login;
    if (isLoggedIn && isAuthRoute) return RouteName.home;
    return null;
  },
  routes: [
    GoRoute(path: RouteName.splash, builder: (_, __) => const SplashPage()),
    GoRoute(path: RouteName.login, builder: (_, __) => const LoginPage()),
    GoRoute(path: RouteName.home, builder: (_, __) => const HomePage()),
    GoRoute(
      path: RouteName.movieDetail,
      builder: (_, state) => MovieDetailPage(movieId: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(path: RouteName.search, builder: (_, __) => const SearchPage()),
    GoRoute(path: RouteName.watchlist, builder: (_, __) => const WatchlistPage()),
    GoRoute(path: RouteName.profile, builder: (_, __) => const ProfilePage()),
  ],
);
```

---

## 7. Error Handling

```dart
// failure.dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}
class NetworkFailure extends Failure {
  const NetworkFailure() : super('Không có kết nối mạng');
}
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

// Repository pattern với Either
Future<Either<Failure, List<MovieEntity>>> getTrendingMovies() async {
  try {
    final result = await remoteDataSource.getTrendingMovies();
    return Right(result.map((m) => m.toEntity()).toList());
  } on DioException catch (e) {
    return Left(ServerFailure(e.message ?? 'Server error'));
  } on SocketException {
    return Left(const NetworkFailure());
  }
}
```

---

## 8. Dependency Injection

```dart
// injection.dart
@InjectableInit()
void configureDependencies() => getIt.init();

// Các module
@module
abstract class NetworkModule {
  @singleton
  Dio get dio => createDioClient();
}

@module
abstract class SupabaseModule {
  @singleton
  SupabaseClient get supabase => Supabase.instance.client;
}

// Đăng ký BLoC với @injectable + @factoryMethod (mỗi lần cần = new instance)
@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> { ... }
```

---

## 9. Key Packages

```yaml
dependencies:
  flutter_bloc: ^8.1.6
  bloc: ^8.1.4
  equatable: ^2.0.5
  get_it: ^7.7.0
  injectable: ^2.4.4
  go_router: ^14.8.1
  dio: ^5.9.0
  supabase_flutter: ^2.9.0
  hive_flutter: ^1.1.0
  dartz: ^0.10.1
  youtube_player_flutter: ^9.1.1
  cached_network_image: ^3.4.1
  carousel_slider: ^5.1.1
  shimmer: ^3.0.0
  flutter_svg: ^2.2.0
  shared_preferences: ^2.5.3

dev_dependencies:
  injectable_generator: ^2.6.2
  build_runner: ^2.4.13
  hive_generator: ^2.0.1
  json_serializable: ^6.9.4
  bloc_test: ^9.1.7
  mocktail: ^1.0.4
  flutter_lints: ^3.0.0
```

---

## 10. Testing Strategy

### Unit Tests (Domain + Data)
- UseCase: mock Repository, kiểm tra logic
- Repository: mock DataSource, kiểm tra Either

### BLoC Tests
```dart
blocTest<HomeBloc, HomeState>(
  'emits [loading, success] when fetch succeeds',
  build: () => HomeBloc(getTrending: mockGetTrending),
  act: (bloc) => bloc.add(HomeFetchRequested()),
  expect: () => [
    HomeState.initial().copyWith(status: HomeStatus.loading),
    HomeState.initial().copyWith(status: HomeStatus.success, trending: fakeMovies),
  ],
);
```

### Widget Tests
- `MovieCard`, `SectionHeader`, error/empty states

### Integration Tests
- Splash → Login → Home → Movie Detail → Add to Watchlist
