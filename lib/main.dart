import 'package:flutter/material.dart';

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
  int _counter = 0;
  int _totalClicks = 0;

  // ==========================================
  // TU JEST "MÓZG" APKI (LOGIKA)
  // To musi być TUTAJ, nad słowem @override
  // ==========================================

  String get _feedbackMessage {
    if (_counter == 0) return "Zacznij klikać, programisto!";
    if (_counter > 0 && _counter <= 10) return "Dobry początek! 👍";
    if (_counter > 10 && _counter <= 20)
      return "Ale szalejesz! 🚀"; // Zmieniliśmy zakres do 20
    if (_counter > 20) return "Aga, TY JESTEŚ MASZYNĄ! 🤖"; // NOWA LINIA
    return "Jesteś na minusie? 😮";
  }

  Color get _cardColor {
    if (_counter == 0) return Colors.white;
    if (_counter > 0) return Colors.green.shade50;
    return Colors.red.shade50;
  }

  IconData get _userIcon {
    if (_counter == 0) return Icons.person;
    if (_counter > 0) return Icons.sentiment_very_satisfied;
    return Icons.sentiment_very_dissatisfied;
  }

  // ==========================================

  void _incrementCounter() {
    setState(() {
      _counter++;
      _totalClicks++;
    });
  }

  void _decrementCounter() {
    setState(() {
      _counter--;
      _totalClicks++;
    });
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // DYNAMICZNA IKONA (LUDZIK)
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.amber,
              child: Icon(_userIcon, size: 80, color: Colors.white),
            ),
            const SizedBox(height: 20),

            // DYNAMICZNY TEKST
            Text(
              _feedbackMessage,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 10),

            // KARTA Z WYNIKIEM
            Card(
              color: _cardColor,
              elevation: 10,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'WYNIK OPERACJI:',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    Text(
                      '$_counter',
                      style: const TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const Divider(),
                    Text(
                      'SUMA KLIKNIĘĆ: $_totalClicks',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // PRZYCISK RESETU
            ElevatedButton.icon(
              onPressed: _resetCounter,
              icon: const Icon(Icons.refresh),
              label: const Text('ZACZNIJ OD NOWA'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade100,
                foregroundColor: Colors.red,
              ),
            ),
          ],
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
