import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failure.dart';

abstract class AuthRepository {
  User? getCurrentUser();
  Future<Either<Failure, AuthResponse>> login(String email, String password);
  Future<Either<Failure, void>> logout();
}
