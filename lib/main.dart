import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/stats_page.dart';
import 'screens/settings_page.dart';
import 'screens/onas_page.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikacja Pawła',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Aplikacja Pawła'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // 1. Odtwarzacz stworzony raz, na samej górze
  final AudioPlayer _player = AudioPlayer();

  String _userName = "";
  int _counter = 0;
  int _totalClicks = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // 2. FUNKCJA GRAJĄCA - jej brakowało!

  void _playKick() async {
    try {
      await _player.play(AssetSource('sounds/kick.mp3'));
    } catch (e) {
      debugPrint("Błąd dźwięku: $e"); // Zmienione z print na debugPrint
    }
  }

  void _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // 1. Sprawdzamy kto teraz gra
      _userName = prefs.getString('activePlayer') ?? "Paweł";

      // 2. Wczytujemy punkty konkretnie dla tej osoby
      // To jest kluczowe: ustawiamy _totalClicks, ale też _counter!
      _totalClicks = prefs.getInt('clicks_$_userName') ?? 0;

      // DODAJ TĘ LINIĘ PONIŻEJ:
      _counter = _totalClicks;
    });
  }

  void _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    String activePlayer = prefs.getString('activePlayer') ?? "Paweł";

    await prefs.setInt('totalClicks', _totalClicks);
    await prefs.setInt('clicks_$activePlayer', _totalClicks);

    // --- TO JEST TA NOWA CZĘŚĆ ---
    // Pobieramy listę wszystkich imion, które już znamy
    List<String> players = prefs.getStringList('all_players') ?? [];

    // Jeśli tego gracza jeszcze nie ma na liście, to go dopisujemy
    if (!players.contains(activePlayer)) {
      players.add(activePlayer);
      await prefs.setStringList('all_players', players);
    }
  }

  String get _feedbackMessage {
    String displayName = _userName.isEmpty ? "Mistrzu" : _userName;
    if (_counter == 0) return "Zacznij klikać, $displayName!";
    if (_counter <= 10) return "Dobry początek, $displayName! 👍";
    if (_counter <= 20) return "Ale szalejesz, $displayName! 🚀";
    return "$displayName, TY JESTEŚ MASZYNĄ! 🤖";
  }

  Color get _userColor {
    if (_counter <= 10) return Colors.blue;
    if (_counter <= 20) return Colors.green;
    return Colors.red;
  }

  IconData get _userIcon {
    if (_counter <= 10) return Icons.person;
    if (_counter <= 20) return Icons.sentiment_very_satisfied;
    return Icons.sentiment_satisfied_alt_rounded;
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
      _totalClicks++;
    });
    _saveData();
    _playKick(); // GRA!
  }

  void _decrementCounter() {
    setState(() {
      _counter--;
      _totalClicks--;
    });
    _saveData();
    _playKick(); // GRA!
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
    _saveData();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Licznik wyzerowany!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.indigo),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.person, size: 50, color: Colors.white),
                  const SizedBox(height: 10),
                  Text(
                    'Witaj, $_userName!',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text('Statystyki'),
              leading: const Icon(Icons.bar_chart),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StatsPage()),
                ).then((_) {
                  // Ta linia odpala się PO zamknięciu ustawień
                  _loadData();
                });
              },
            ),
            ListTile(
              title: const Text('Ustawienia'),
              leading: const Icon(Icons.settings),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                ).then((_) {
                  _loadData();
                });
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.info_outline,
              ), // Fajnie dodać ikonkę info
              title: const Text('O nas'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OnasPage(),
                  ), // Tu musi być nazwa klasy z punktu nr 2
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        color: Colors.blue.shade100,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _feedbackMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_userIcon, size: 80, color: _userColor),
                      const SizedBox(height: 10),
                      const Text(
                        'WYNIK OPERACJI:',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        '$_counter',
                        style: TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: _userColor,
                        ),
                      ),
                      const Divider(),
                      Text('SUMA KLIKNIĘĆ: $_totalClicks'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _resetCounter,
                icon: const Icon(Icons.refresh),
                label: const Text('ZACZNIJ OD NOWA'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: _decrementCounter,
              backgroundColor: Colors.red,
              heroTag: "btn1",
              child: const Icon(Icons.remove),
            ),
            const SizedBox(width: 10),
            FloatingActionButton(
              onPressed: _incrementCounter,
              backgroundColor: Colors.orange,
              heroTag: "btn2",
              child: const Icon(Icons.thumb_up),
            ),
          ],
        ),
      ),
    );
  }
}
