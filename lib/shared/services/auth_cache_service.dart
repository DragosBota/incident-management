import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/models/profile.dart';

class AuthCacheService {
  AuthCacheService._();

  static final AuthCacheService instance = AuthCacheService._();

  static const String _profileKey = 'cached_profile';
  static const String _departmentNameKey = 'cached_department_name';
  static const String _departmentsKey = 'cached_departments';

  Future<void> cacheProfile(Profile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _profileKey,
      jsonEncode(profile.toMap()),
    );
  }

  Future<Profile?> getCachedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final rawProfile = prefs.getString(_profileKey);

    if (rawProfile == null || rawProfile.isEmpty) {
      return null;
    }

    return Profile.fromMap(
      Map<String, dynamic>.from(jsonDecode(rawProfile) as Map),
    );
  }

  Future<void> cacheDepartmentName(String departmentName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_departmentNameKey, departmentName);
  }

  Future<String?> getCachedDepartmentName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_departmentNameKey);
  }

  Future<void> cacheDepartments(List<Map<String, dynamic>> departments) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _departmentsKey,
      jsonEncode(departments),
    );
  }

  Future<List<Map<String, dynamic>>> getCachedDepartments() async {
    final prefs = await SharedPreferences.getInstance();
    final rawDepartments = prefs.getString(_departmentsKey);

    if (rawDepartments == null || rawDepartments.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(rawDepartments) as List<dynamic>;

    return decoded
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
    await prefs.remove(_departmentNameKey);
    await prefs.remove(_departmentsKey);
  }
}
