import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Pozdrawiamy z macbooka Gem i Paw'),
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

  void _incrementCounter() {
    setState(() {
      _counter = _counter + 5;
      _totalClicks++;
    });
  }

  void _decrementCounter() {
    setState(() {
      _counter = _counter - 1;
      _totalClicks++;
    });
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
      _totalClicks++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 97, 162, 206),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'klikaj teraz hahaha',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 10),
            // TWOJA GWIAZDKA!
            const Icon(Icons.stars, size: 80, color: Colors.amber),
            const SizedBox(height: 10),
            Text(
              '$_counter',
              style: TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                color: _counter < 0 ? Colors.red : Colors.greenAccent,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'SUMA KLIKNIĘĆ: $_totalClicks',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
          ], // <-- Tutaj był błąd, teraz jest tylko jedno domknięcie listy!
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _decrementCounter,
            backgroundColor: Colors.red,
            tooltip: 'Odejmij',
            child: const Icon(Icons.remove),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: _incrementCounter,
            backgroundColor: Colors.orange,
            tooltip: 'Dodaj',
            child: const Icon(Icons.thumb_up),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: _resetCounter,
            backgroundColor: const Color.fromARGB(255, 77, 9, 204),
            tooltip: 'Reset',
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}
