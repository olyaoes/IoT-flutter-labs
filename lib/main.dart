import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lab1_water/cubits/water_cubit.dart';
import 'package:lab1_water/repositories/water_repository.dart';
import 'package:lab1_water/screens/home_page.dart';
import 'package:lab1_water/screens/login_page.dart';
import 'package:lab1_water/screens/register_page.dart';
import 'package:lab1_water/screens/splash_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<WaterRepository>(
      create: (BuildContext context) => WaterRepository(),
      child: BlocProvider<WaterCubit>(
        create: (BuildContext context) => WaterCubit(
          context.read<WaterRepository>(),
        )..loadData(),
        child: MaterialApp(
          title: 'AquaTracker',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(primarySwatch: Colors.blue),
          home: const SplashPage(),
          routes: <String, WidgetBuilder>{
            '/home': (BuildContext context) => const HomePage(),
            '/login': (BuildContext context) => const LoginPage(),
            '/register': (BuildContext context) => const RegisterPage(),
          },
        ),
      ),
    );
  }
}
