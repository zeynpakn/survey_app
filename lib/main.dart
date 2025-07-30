import 'package:flutter/material.dart';
import 'package:survey_app/screens/user_home.dart';
import 'screens/login.dart';
import 'screens/admin_home.dart';
import 'services/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SQLite veritabanını başlat
  await DatabaseHelper().database;

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
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}
