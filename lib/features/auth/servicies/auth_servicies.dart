import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/services/supabase_service.dart';
import '../models/profile.dart';


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


  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<void> createProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String departmentId,
  }) async {
    try {
      await _client.from('profiles').insert({
        'id': userId,
        'first_name': firstName,
        'last_name': lastName,
        'department_id': departmentId,
      });
    } catch (e) {
      throw Exception('Error creating profile: $e');
    }
  }

  // Fetches the list of departments from the database.
  Future<List<Map<String, dynamic>>> fetchDepartments() async {
    final response = await _client
      .from('departments')
      .select('id, name')
      .order('name');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Profile> fetchProfile(String userId) async {
  final response = await _client
      .from('profiles')
      .select()
      .eq('id', userId)
      .single();

  return Profile.fromMap(response);
}

  // Signs out the currently authenticated user.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}