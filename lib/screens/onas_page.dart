import 'package:flutter/material.dart';

class OnasPage extends StatelessWidget {
  const OnasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("O nas"), backgroundColor: Colors.green),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("To będzie opis o nas", style: TextStyle(fontSize: 18)),

            const SizedBox(height: 30),

            // Zdjęcie sukcesu!
            Image.asset(
              'assets/images/sukces.png',
              width: 250,
              height: 250,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Wróć"),
            ),
          ],
        ),
      ),
    ); // <-- Tu domykamy Scaffold
  } // <-- Tu domykamy metodę build
} // <-- Tu domykamy klasę
