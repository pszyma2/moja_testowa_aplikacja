import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  // Funkcja, która idzie do "magazynu" po dane
  Future<Map<String, int>> _getStats() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'counter': prefs.getInt('counter') ?? 0,
      'total': prefs.getInt('totalClicks') ?? 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Twoje Statystyki'),
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder<Map<String, int>>(
        future: _getStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildStatCard(
                  'Obecny stan licznika',
                  '${data['counter']}',
                  Icons.calculate,
                  Colors.blue,
                ),
                const SizedBox(height: 20),
                _buildStatCard(
                  'Suma wszystkich kliknięć',
                  '${data['total']}',
                  Icons.ads_click,
                  Colors.green,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Pomocniczy "widżet", żeby nie pisać dwa razy tego samego kodu dla karty
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, color: color, size: 40),
        title: Text(title),
        subtitle: Text(
          value,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}
