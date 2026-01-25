import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final AudioPlayer _statsPlayer = AudioPlayer();
  List<Map<String, dynamic>> _playerResults = [];

  @override
  void initState() {
    super.initState();
    _playBackgroundMusic();
    _loadAllResults();
  }

  void _playBackgroundMusic() async {
    try {
      await _statsPlayer.setReleaseMode(ReleaseMode.loop);
      await _statsPlayer.play(AssetSource('sounds/champions.mp3'));
    } catch (e) {
      debugPrint("Błąd muzyki: $e");
    }
  }

  void _loadAllResults() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> playerNames = prefs.getStringList('all_players') ?? ["Paweł"];
    List<Map<String, dynamic>> results = [];

    for (String name in playerNames) {
      int score = prefs.getInt('clicks_$name') ?? 0;
      results.add({'name': name, 'score': score});
    }

    results.sort((a, b) => b['score'].compareTo(a['score']));

    setState(() {
      _playerResults = results;
    });
  }

  @override
  void dispose() {
    _statsPlayer.stop();
    _statsPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tabela Ligi Mistrzów"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade900, Colors.blue.shade100],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _playerResults.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return const Card(
                color: Colors.amber,
                child: ListTile(
                  leading: Icon(Icons.star, color: Colors.indigo),
                  title: Text(
                    "WYNIKI GRACZY",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }

            var player = _playerResults[index - 1];
            return Card(
              child: ListTile(
                leading: Icon(
                  index == 1 ? Icons.emoji_events : Icons.person,
                  color: index == 1 ? Colors.amber : Colors.grey,
                ),
                title: Text(
                  player['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Text(
                  "${player['score']} pkt",
                  style: const TextStyle(
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
