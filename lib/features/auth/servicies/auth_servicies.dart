import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/services/supabase_service.dart';
import '../models/profile.dart';

class AuthService {
  final SupabaseClient _client = SupabaseService.client;

  User? get currentUser => _client.auth.currentUser;

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

  Future<String?> fetchDepartmentIdByName(String departmentName) async {
    final response = await _client
        .from('departments')
        .select('id')
        .ilike('name', departmentName)
        .maybeSingle();

    if (response == null) return null;

    return response['id'] as String?;
  }

  Future<String?> fetchCurrentUserDepartmentId() async {
    final user = currentUser;

    if (user == null) return null;

    final profile = await fetchProfile(user.id);
    return profile.departmentId;
  }

  Future<String?> fetchCurrentUserDepartmentName() async {
    final user = currentUser;

    if (user == null) return null;

    final profile = await fetchProfile(user.id);

    final response = await _client
        .from('departments')
        .select('name')
        .eq('id', profile.departmentId)
        .maybeSingle();

    if (response == null) return null;

    return response['name'] as String?;
  }

  Future<bool> isCurrentUserFromDepartment(String departmentName) async {
    final currentDepartmentId = await fetchCurrentUserDepartmentId();
    final targetDepartmentId = await fetchDepartmentIdByName(departmentName);

    if (currentDepartmentId == null || targetDepartmentId == null) {
      return false;
    }

    return currentDepartmentId == targetDepartmentId;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}