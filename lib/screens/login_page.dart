import 'package:flutter/material.dart';
import 'package:lab1_water/widgets/app_button.dart';
import 'package:lab1_water/widgets/app_input.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
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
                  Icon(
                    Icons.water_drop,
                    size: size.width > 600 ? 120 : 80,
                    color: const Color(0xFF0072FF),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'AquaBalance',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 50),
                  const AppInput(hint: 'Email'),
                  const AppInput(hint: 'Password', isPass: true),
                  const SizedBox(height: 20),
                  AppButton(
                    text: 'LOGIN',
                    onPress: () {
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text('Create an account'),
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
