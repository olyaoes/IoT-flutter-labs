import 'package:flutter/material.dart';
import 'package:lab1_water/models/user_model.dart';
import 'package:lab1_water/repositories/shared_prefs_user_repository.dart';
import 'package:lab1_water/widgets/app_button.dart';
import 'package:lab1_water/widgets/app_input.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  final SharedPrefsUserRepository _repo = SharedPrefsUserRepository();

  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final UserModel? user = await _repo.getUser();
    if (user != null) {
      _currentUser = user;
      _nameController.text = user.fullName;
      _goalController.text = user.dailyGoal.toString();
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_currentUser == null) {
      return;
    }

    final String newName = _nameController.text.trim();
    final String goalText = _goalController.text.trim();
    final int? newGoal = int.tryParse(goalText);

    if (newName.isEmpty || newGoal == null || newGoal <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid name or goal'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final UserModel updatedUser = UserModel(
      fullName: newName,
      email: _currentUser!.email,
      password: _currentUser!.password,
      dailyGoal: newGoal,
    );

    await _repo.saveUser(updatedUser);

    if (!mounted) return;
    setState(() {
      _currentUser = updatedUser;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF1A1A1A),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Colors.white, Color(0xFFE0F7FA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0xFF0072FF),
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _currentUser?.email ?? 'No Email',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 40),
                  AppInput(
                    hint: 'Full Name',
                    controller: _nameController,
                  ),
                  AppInput(
                    hint: 'Daily Goal (ml)',
                    controller: _goalController,
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    text: 'SAVE CHANGES',
                    onPress: _saveChanges,
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    text: 'LOGOUT',
                    onPress: _logout,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
