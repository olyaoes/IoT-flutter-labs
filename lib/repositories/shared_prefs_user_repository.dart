import 'dart:convert';
import 'package:lab1_water/models/user_model.dart';
import 'package:lab1_water/repositories/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsUserRepository implements UserRepository {
  static const String _userKey = 'user_data';

  @override
  Future<void> saveUser(UserModel user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String userData = jsonEncode(user.toJson());
    await prefs.setString(_userKey, userData);
  }

  @override
  Future<UserModel?> getUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userData = prefs.getString(_userKey);

    if (userData != null) {
      final dynamic decodedData = jsonDecode(userData);
      final Map<String, dynamic> json = decodedData as Map<String, dynamic>;
      return UserModel.fromJson(json);
    }

    return null;
  }

  @override
  Future<void> deleteUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  @override
  Future<bool> login(String email, String password) async {
    final UserModel? user = await getUser();

    if (user != null) {
      return user.email == email && user.password == password;
    }

    return false;
  }
}
