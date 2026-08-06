import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/supabase_constants.dart';

abstract class AuthRemoteDataSource {
  User? getCurrentUser();
  Future<AuthResponse> login(String email, String password);
  Future<AuthResponse> register(String email, String password);
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
    return response;
  }

  @override
  Future<void> logout() async {
    await supabaseClient.auth.signOut();
  }
}

