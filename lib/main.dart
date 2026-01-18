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

  // FUNKCJA DODAWANIA
  void _incrementCounter() {
    setState(() {
      _counter = _counter + 5;
    });
  }

  // FUNKCJA ODEJMOWANIA (Teraz jest w dobrym miejscu!)
  void _decrementCounter() {
    setState(() {
      _counter = _counter - 1;
    });
  }

  void _resetCounter() {
    setState(() {
      _counter = 0; // ustawiamy zero
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('naciskaj moze ci sie uda hahaha:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _decrementCounter,
            backgroundColor: Colors.red,
            child: const Icon(Icons.remove),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: _incrementCounter,
            backgroundColor: Colors.orange,
            child: const Icon(Icons.thumb_up),
          ),
          FloatingActionButton(
            onPressed: _resetCounter,
            backgroundColor: Colors.grey,
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    ); // <-- Tu brakowało nawiasów
  }
}
