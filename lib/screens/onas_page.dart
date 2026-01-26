import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class OnasPage extends StatelessWidget {
  const OnasPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Tworzymy odtwarzacz wewnątrz strony
    final AudioPlayer audioPlayer = AudioPlayer();

    return Scaffold(
      appBar: AppBar(
        title: const Text('O nas'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Nasze Sukcesy!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // TWOJE ZDJĘCIE Z REAKCJĄ NA DOTYK
            GestureDetector(
              onTap: () async {
                // Tu wpisujemy Twój plik .wav!
                await audioPlayer.play(AssetSource('sounds/hou.wav'));
              },
              child: Image.asset(
                'assets/images/sukces.png',
                width: 300,
                height: 300,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 20),
            const Text('Kliknij w nas, aby usłyszeć radość!'),
          ],
        ),
      ),
    );
  }
}
