import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  double? temperature;
  double? windSpeed;
  double? humidity;
  bool isLoading = true;
  String? error;

  final List<Map<String, dynamic>> todos = [
    {'title': 'Datenbanksysteme lernen', 'done': false},
    {'title': 'Hausübung 2 abgeben', 'done': false},
    {'title': 'Algorithmen wiederholen', 'done': true},
  ];

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    try {
      final response = await http.get(Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=50.58&longitude=8.68&current=temperature_2m,relative_humidity_2m,wind_speed_10m&timezone=Europe%2FBerlin',
      ));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          temperature = data['current']['temperature_2m'].toDouble();
          windSpeed = data['current']['wind_speed_10m'].toDouble();
          humidity = data['current']['relative_humidity_2m'].toDouble();
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Fehler beim Laden der Wetterdaten';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Keine Verbindung möglich';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Mein Dashboard'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Wetter', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : error != null
                        ? Text(error!, style: const TextStyle(color: Colors.red))
                        : Column(
                            children: [
                              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                                _weatherTile('🌡️ Temperatur', '${temperature}°C'),
                                _weatherTile('💨 Wind', '${windSpeed} km/h'),
                                _weatherTile('💧 Luftfeuchtigkeit', '${humidity}%'),
                              ]),
                            ],
                          ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Aufgaben', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: todos.map((todo) => ListTile(
                    leading: Icon(
                      todo['done'] ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: todo['done'] ? Colors.green : Colors.grey,
                    ),
                    title: Text(todo['title']),
                  )).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _weatherTile(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}