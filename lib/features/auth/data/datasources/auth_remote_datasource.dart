import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/supabase_constants.dart';

abstract class AuthRemoteDataSource {
  User? getCurrentUser();
  Future<AuthResponse> login(String email, String password);
  Future<AuthResponse> register(String email, String password);
  Future<void> resetPassword(String email);
  Future<void> logout();
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl(this.supabaseClient);

  @override
  User? getCurrentUser() {
    return supabaseClient.auth.currentUser;
  }

  @override
  Future<AuthResponse> login(String email, String password) async {
    return await supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<AuthResponse> register(String email, String password) async {
    try {
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
      );
      if (response.user != null) {
        try {
          await supabaseClient.from(SupabaseConstants.profilesTable).upsert({
            'id': response.user!.id,
            'email': email,
            'created_at': DateTime.now().toIso8601String(),
          });
        } catch (_) {}
      }

      if (response.session == null) {
        try {
          final loginResponse = await supabaseClient.auth.signInWithPassword(
            email: email,
            password: password,
          );
          if (loginResponse.session != null) {
            return loginResponse;
          }
        } catch (_) {}
      }

      return response;
    } on AuthException catch (_) {
      try {
        final loginResponse = await supabaseClient.auth.signInWithPassword(
          email: email,
          password: password,
        );
        if (loginResponse.user != null) {
          return loginResponse;
        }
      } catch (_) {}
      rethrow;
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    await supabaseClient.auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> logout() async {
    await supabaseClient.auth.signOut();
  }
}

