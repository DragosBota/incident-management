import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/services/supabase_service.dart';


class AuthService {
  final SupabaseClient _client = SupabaseService.client;

  // Returns the currently authenticated user, if any.
  // If no user is logged in, this getter returns `null`.
  User? get currentUser => _client.auth.currentUser;

  // Attempts to sign in a user using email and password.
  // Throws an exception if authentication fails.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Attempts to register a new user using email and password.
  // This creates the authentication account in Supabase Auth.
  // Additional user profile data will be stored separatelyin the `profiles` table in a later step.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  // Signs out the currently authenticated user.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}