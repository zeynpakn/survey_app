import 'package:flutter/material.dart';
import 'package:survey_app/screens/survey_screen.dart';
import 'package:survey_app/screens/user_home.dart';
import 'screens/login.dart';
import 'screens/admin_home.dart';

void main() {
  runApp(const SurveyApp());
}

class SurveyApp extends StatelessWidget {
  const SurveyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Survey App',
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
      routes: {
        '/user_home': (context) {
          final username = ModalRoute.of(context)!.settings.arguments as String;
          return UserHome(username: username);
        },
        '/admin_home': (context) => const AdminHome(),
        '/survey': (context) => const SurveyScreen(),
        '/login' :   (context) => const LoginScreen(),
      }, 
    );
  }
}