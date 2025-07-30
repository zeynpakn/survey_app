import 'package:flutter/material.dart';
import 'survey_screen.dart';

class UserHome extends StatelessWidget {
  final String username;

  const UserHome({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hoş Geldiniz $username"),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 232, 108, 149),
      ),
      body: Stack(
        children: [
          _buildLogoutButton(context),
          Center(child: _buildSurveyButton(context)),
        ],
      ),
    );
  }

  //logout
  Widget _buildLogoutButton(BuildContext context) {
    return Positioned(
      top: 16,
      right: 16,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/login');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 37, 126, 181),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: const Text("Çıkış Yap"),
      ),
    );
  }

  // anket
  Widget _buildSurveyButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SurveyScreen(username: username),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.pink.shade200,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
      child: const Text("Ankete Katıl", style: TextStyle(fontSize: 18)),
    );
  }
}
