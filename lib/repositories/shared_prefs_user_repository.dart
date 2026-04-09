import 'dart:convert';
import 'package:lab1_water/models/user_model.dart';
import 'package:lab1_water/repositories/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsUserRepository implements UserRepository {
  static const String _usersListKey = 'all_users_list';
  static const String _currentUserKey = 'current_logged_user';

  @override
  Future<void> saveUser(UserModel user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<UserModel> users = await _getAllUsers();
    
    users.removeWhere((UserModel u) => u.email == user.email);
    users.add(user);

    final List<String> encodedUsers = users
        .map((UserModel u) => jsonEncode(u.toJson()))
        .toList();
    
    await prefs.setStringList(_usersListKey, encodedUsers);
  }

  Future<List<UserModel>> _getAllUsers() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? encodedUsers = prefs.getStringList(_usersListKey);

    if (encodedUsers == null) {
      return <UserModel>[];
    }

    return encodedUsers.map((String s) {
      final dynamic decoded = jsonDecode(s);
      return UserModel.fromJson(decoded as Map<String, dynamic>);
    }).toList();
  }

  @override
  Future<UserModel?> getUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userData = prefs.getString(_currentUserKey);

    if (userData != null) {
      final dynamic decoded = jsonDecode(userData);
      return UserModel.fromJson(decoded as Map<String, dynamic>);
    }
    return null;
  }

  @override
  Future<void> deleteUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  @override
  Future<bool> login(String email, String password) async {
    final List<UserModel> users = await _getAllUsers();
    
    for (final UserModel user in users) {
      if (user.email == email && user.password == password) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
        return true;
      }
    }
    return false;
  }
}
