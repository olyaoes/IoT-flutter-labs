import 'package:flutter/material.dart';
import 'package:lab1_water/models/user_model.dart';
import 'package:lab1_water/repositories/shared_prefs_user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _waterController = TextEditingController();
  final SharedPrefsUserRepository _repo = SharedPrefsUserRepository();

  int _dailyGoal = 2000;
  int _currentWater = 0;
  int _lastLog = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final UserModel? user = await _repo.getUser();
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (mounted) {
      setState(() {
        if (user != null) {
          _dailyGoal = user.dailyGoal;
        }
        _currentWater = prefs.getInt('current_water') ?? 0;
        _lastLog = prefs.getInt('last_log') ?? 0;
        _isLoading = false;
      });
    }
  }

  Future<void> _logWater() async {
    final String input = _waterController.text.trim();
    final int? amount = int.tryParse(input);

    if (amount == null || amount <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int newWater = _currentWater + amount;

    await prefs.setInt('current_water', newWater);
    await prefs.setInt('last_log', amount);

    if (mounted) {
      setState(() {
        _currentWater = newWater;
        _lastLog = amount;
        _waterController.clear();
      });
    }
  }

  @override
  void dispose() {
    _waterController.dispose();
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
      backgroundColor: const Color(0xFFE0F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BFFF),
        title: const Text(
          'AquaTracker',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/profile').then((_) {
                _loadData();
              });
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '$_currentWater / $_dailyGoal ml',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Last log: +$_lastLog ml',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 40),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: TextField(
                    controller: _waterController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Enter amount (ml)',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _logWater,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BFFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'LOG WATER',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
