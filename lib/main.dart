import 'package:flutter/material.dart';
import 'package:lab1_water/screens/home_page.dart';
import 'package:lab1_water/screens/login_page.dart';
import 'package:lab1_water/screens/profile_page.dart';
import 'package:lab1_water/screens/register_page.dart';

void main() {
  runApp(const AquaApp());
}

class AquaApp extends StatelessWidget {
  const AquaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AquaBalance',
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => const LoginPage(),
        '/register': (BuildContext context) => const RegisterPage(),
        '/home': (BuildContext context) => const HomePage(),
        '/profile': (BuildContext context) => const ProfilePage(),
      },
    );
  }
}
