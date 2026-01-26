import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _nameController = TextEditingController();
  final List<String> _players = ["Paweł", "Aga", "Zuza", "Gaba", "James"];
  String _selectedPlayer = "Paweł";
  @override
  void initState() {
    super.initState();
    _loadName();
  }

  void _loadName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('userName') ?? "";
    });
  }

  void _selectPlayer(String name) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedPlayer = name;
    });
    // To sprawi, że apka zapamięta, kto teraz rządzi na Samsungu!
    await prefs.setString('activePlayer', name);
  }

  void _clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      _nameController.clear();
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pamięć aplikacji wyczyszczona!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ustawienia')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profil użytkownika',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Column(
                children: _players.map((name) {
                  return Card(
                    elevation: _selectedPlayer == name ? 4 : 1,
                    color: _selectedPlayer == name
                        ? Colors.blue[50]
                        : Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: Icon(
                        Icons.sports_soccer,
                        color: _selectedPlayer == name
                            ? Colors.blue
                            : Colors.grey,
                      ),
                      title: Text(
                        name,
                        style: TextStyle(
                          color: _selectedPlayer == name
                              ? Colors.blue[900]
                              : Colors.black,
                          fontWeight: _selectedPlayer == name
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: _selectedPlayer == name
                          ? const Icon(Icons.check_circle, color: Colors.blue)
                          : null,
                      onTap: () => _selectPlayer(name),
                    ),
                  );
                }).toList(),
              ), // Ten przecinek i nawias są kluczowe!

              const SizedBox(height: 40),
              const Divider(),
              const Text(
                'Strefa Niebezpieczna',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _clearAllData,
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('WYCZYŚĆ WSZYSTKIE DANE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    foregroundColor: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
