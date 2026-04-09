import 'package:flutter/material.dart';
import 'package:lab1_water/widgets/app_button.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF00C6FF),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 20),
                const CircleAvatar(
                  radius: 60,
                  backgroundColor: Color(0xFF0072FF),
                  child: Icon(Icons.person, size: 60, color: Colors.white),
                ),
                const SizedBox(height: 30),
                const ListTile(
                  leading: Icon(Icons.person_outline),
                  title: Text('User Name'),
                  subtitle: Text('Water Lover'),
                ),
                const ListTile(
                  leading: Icon(Icons.email_outlined),
                  title: Text('Email'),
                  subtitle: Text('user@example.com'),
                ),
                const ListTile(
                  leading: Icon(Icons.flag_outlined),
                  title: Text('Daily Goal'),
                  subtitle: Text('2000 ml'),
                ),
                const Spacer(),
                AppButton(
                  text: 'LOGOUT',
                  onPress: () {
                    Navigator.pushReplacementNamed(context, '/');
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
