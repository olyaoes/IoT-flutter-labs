import 'package:flutter/material.dart';
import 'package:lab1_water/widgets/app_button.dart';
import 'package:lab1_water/widgets/app_input.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const Color _aeroBlue = Color(0xFF00C6FF);
  static const Color _darkSlate = Color(0xFF1A1A1A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AquaTracker'),
        backgroundColor: _aeroBlue,
        foregroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
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
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 50),
                  const Text(
                    '100 / 2000 ml',
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                      color: _darkSlate,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Last log: +100 ml',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 50),
                  const AppInput(hint: 'Enter mL'),
                  const SizedBox(height: 15),
                  AppButton(
                    text: 'LOG WATER',
                    onPress: () {},
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
