import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String _userName = ""; // Tu będziemy trzymać imię
  final TextEditingController _nameController =
      TextEditingController(); // Kontroler do pola tekstowego

  int _counter = 0;
  int _totalClicks = 0;
  @override
  void initState() {
    super.initState();
    _loadData();
    // To uruchamia szafkę z pamięcią przy starcie apki
  }

  // czy tutaj bedzie dobrze "nad getterami"
  // Wczytywanie danych przy starcie
  void _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = prefs.getInt('counter') ?? 0;
      _totalClicks = prefs.getInt('totalClicks') ?? 0;
    });
    _userName = prefs.getString('userName') ?? "";
    _nameController.text = _userName; // To wpisze imię do okienka przy starcie
  }

  // Zapisywanie danych przy każdym kliknięciu
  void _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('counter', _counter);
    prefs.setInt('totalClicks', _totalClicks);
    prefs.setString('userName', _userName);
  }

  // Gettery hah
  // LOGIKA KOMUNIKATÓW
  String get _feedbackMessage {
    // Jeśli imię jest puste, użyjemy słowa "Mistrzu"
    String displayName = _userName.isEmpty ? "Mistrzu" : _userName;

    if (_counter == 0) return "Zacznij klikać, $displayName!";
    if (_counter <= 10) return "Dobry początek, $displayName! 👍";
    if (_counter <= 20) return "Ale szalejesz, $displayName! 🚀";
    return "$displayName, TY JESTEŚ MASZYNĄ! 🤖"; // Twoja wersja "Maszyny"
  }

  // LOGIKA KOLORÓW KARTY
  // LOGIKA KOLORÓW
  Color get _userColor {
    if (_counter <= 10) return Colors.blue;
    if (_counter <= 20) return Colors.green;
    return Colors.red;
  }

  // LOGIKA IKON
  IconData get _userIcon {
    if (_counter <= 10) return Icons.person;
    if (_counter <= 20) return Icons.sentiment_very_satisfied;
    if (_counter > 20) return Icons.sentiment_satisfied_alt_rounded;
    return Icons.sentiment_very_dissatisfied;
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
      _totalClicks++;
    });
    _saveData();
  }

  void _decrementCounter() {
    setState(() {
      _counter--;
      _totalClicks++;
    });
    _saveData(); //ZAPISYWANIE W PRZYCISKACH
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
    _saveData(); //ZEROWANIE TEZ SIE ZAPISUJE
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
      body: Container(
        width: double.infinity,
        color: Colors.blue.shade100,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 0. POLE TEKSTOWE DLA IMIENIA
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 10,
                ),
                child: TextField(
                  controller: _nameController,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    hintText: 'Wpisz imię...',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white70,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _userName = value;
                    });
                    _saveData();
                  },
                ),
              ),

              // 1. TWOJE KOMUNIKATY (To co już masz)
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

              // 2. TWOJA KARTA (To co już masz)
              Card(
                elevation: 8,

                // ... reszta Twojego kodu karty ...
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

              // 3. PRZYCISK RESETU (Uruchamia _resetCounter)
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
