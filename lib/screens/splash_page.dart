import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:lab1_water/models/user_model.dart';
import 'package:lab1_water/repositories/shared_prefs_user_repository.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNetwork();
  }

  Future<void> _checkAuthAndNetwork() async {
    await Future<void>.delayed(const Duration(seconds: 1));

    final List<ConnectivityResult> conn = 
        await Connectivity().checkConnectivity();
    final bool hasInternet = !conn.contains(ConnectivityResult.none);

    final SharedPrefsUserRepository repo = SharedPrefsUserRepository();
    final UserModel? user = await repo.getUser();

    if (!mounted) return;

    if (user != null) {
      if (!hasInternet) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Offline mode. Data may not sync.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF00BFFF),
      body: Center(
        child: Icon(
          Icons.water_drop,
          size: 100,
          color: Colors.white,
        ),
      ),
    );
  }
}
