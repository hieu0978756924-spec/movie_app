import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_app/core/di/injection.dart';
import 'package:movie_app/core/theme/theme_cubit.dart';
import 'package:movie_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:movie_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:movie_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:movie_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:movie_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await GetIt.instance.reset();
    configureDependencies();
  });

  group('Dependency Injection Tests', () {
    test('Core singletons and modules are registered in GetIt', () {
      expect(getIt.isRegistered<Dio>(), isTrue);
      expect(getIt.isRegistered<SupabaseClient>(), isTrue);
      expect(getIt.isRegistered<GoRouter>(), isTrue);
      expect(getIt.isRegistered<ThemeCubit>(), isTrue);
    });

    test('Auth feature Clean Architecture layers are correctly registered', () {
      expect(getIt.isRegistered<AuthRemoteDataSource>(), isTrue);
      expect(getIt.isRegistered<AuthRepository>(), isTrue);
      expect(getIt.isRegistered<LoginUseCase>(), isTrue);
      expect(getIt.isRegistered<GetCurrentUserUseCase>(), isTrue);
      expect(getIt.isRegistered<AuthBloc>(), isTrue);
    });

    test('AuthBloc can be resolved without circular dependency errors', () {
      final authBloc = getIt<AuthBloc>();
      expect(authBloc, isNotNull);
      expect(authBloc.state, equals(AuthInitialState()));
    });
  });
}
