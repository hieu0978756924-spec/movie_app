import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  User? getCurrentUser() {
    return remoteDataSource.getCurrentUser();
  }

  String _mapErrorMessage(Object e) {
    final str = e.toString().toLowerCase();
    if (str.contains('socketexception') ||
        str.contains('failed host lookup') ||
        str.contains('clientexception') ||
        str.contains('connection refused') ||
        str.contains('no address associated with hostname')) {
      return 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng!';
    }
    if (e is AuthException) {
      if (e.code == 'invalid_credentials' ||
          e.message.contains('Invalid login credentials')) {
        return 'Email hoặc mật khẩu không chính xác.';
      }
      if (e.code == 'user_already_exists' ||
          e.message.contains('User already registered') ||
          e.message.contains('already exists')) {
        return 'Email này đã được đăng ký tài khoản. Vui lòng chọn Đăng nhập.';
      }
      if (e.code == 'over_email_send_rate_limit' ||
          e.message.toLowerCase().contains('rate limit exceeded')) {
        return 'Đã vượt quá giới hạn gửi email của Supabase. Vui lòng chờ 1-2 phút hoặc bấm "Đăng nhập ngay" bên dưới.';
      }
      return e.message;
    }
    return 'Đã xảy ra lỗi kết nối: ${e.toString()}';
  }

  @override
  Future<Either<Failure, AuthResponse>> login(
      String email, String password) async {
    try {
      final response = await remoteDataSource.login(email, password);
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(_mapErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> register(
      String email, String password) async {
    try {
      final response = await remoteDataSource.register(email, password);
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(_mapErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(_mapErrorMessage(e)));
    }
  }
}
