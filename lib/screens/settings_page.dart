import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ustawienia'),
        backgroundColor: Colors.green, // Jeszcze inny kolor
      ),
      body: const Center(
        child: Text('Opcje aplikacji ⚙️', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
