import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

void main() => runApp(const MaterialApp(
      home: WeatherApp(),
      debugShowCheckedModeBanner: false,
    ));

// --- Model ---
class Weather {
  final String city, country, description, main;
  final double temp, feelsLike, tempMin, tempMax;
  final int humidity, windSpeed;

  Weather({
    required this.city,
    required this.country,
    required this.description,
    required this.main,
    required this.temp,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.windSpeed,
  });

  factory Weather.fromJson(Map<String, dynamic> j) => Weather(
        city: j['name'],
        country: j['sys']['country'],
        description: j['weather'][0]['description'],
        main: j['weather'][0]['main'],
        temp: (j['main']['temp'] as num).toDouble(),
        feelsLike: (j['main']['feels_like'] as num).toDouble(),
        tempMin: (j['main']['temp_min'] as num).toDouble(),
        tempMax: (j['main']['temp_max'] as num).toDouble(),
        humidity: j['main']['humidity'],
        windSpeed: (j['wind']['speed'] as num).toInt(),
      );
}

// --- App ---
class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});
  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  // Replace with your OpenWeatherMap API key
  static const _apiKey = 'YOUR_API_KEY_HERE';

  Weather? _weather;
  bool _loading = false;
  String _error = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchByLocation();
  }

  Future<void> _fetchByLocation() async {
    setState(() { _loading = true; _error = ''; });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw 'Location services are disabled.';

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) throw 'Location permission denied.';
      }
      if (perm == LocationPermission.deniedForever) throw 'Location permission permanently denied.';

      final pos = await Geolocator.getCurrentPosition();
      await _fetchWeather('https://api.openweathermap.org/data/2.5/weather?lat=${pos.latitude}&lon=${pos.longitude}&appid=$_apiKey&units=metric');
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _fetchByCity(String city) async {
    if (city.trim().isEmpty) return;
    setState(() { _loading = true; _error = ''; });
    await _fetchWeather('https://api.openweathermap.org/data/2.5/weather?q=${Uri.encodeComponent(city)}&appid=$_apiKey&units=metric');
  }

  Future<void> _fetchWeather(String url) async {
    try {
      final res = await http.get(Uri.parse(url));
      final data = jsonDecode(res.body);
      if (res.statusCode != 200) throw data['message'] ?? 'Failed to fetch weather';
      setState(() { _weather = Weather.fromJson(data); _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  // --- Weather icon & gradient based on condition ---
  IconData _getIcon(String main) {
    switch (main.toLowerCase()) {
      case 'clear': return Icons.wb_sunny;
      case 'clouds': return Icons.cloud;
      case 'rain': return Icons.grain;
      case 'drizzle': return Icons.water_drop;
      case 'thunderstorm': return Icons.thunderstorm;
      case 'snow': return Icons.ac_unit;
      case 'mist':
      case 'fog':
      case 'haze': return Icons.foggy;
      default: return Icons.wb_cloudy;
    }
  }

  List<Color> _getGradient(String main) {
    switch (main.toLowerCase()) {
      case 'clear': return [const Color(0xFFFF9800), const Color(0xFF2196F3)];
      case 'clouds': return [const Color(0xFF607D8B), const Color(0xFF90A4AE)];
      case 'rain':
      case 'drizzle': return [const Color(0xFF1565C0), const Color(0xFF42A5F5)];
      case 'thunderstorm': return [const Color(0xFF212121), const Color(0xFF546E7A)];
      case 'snow': return [const Color(0xFFB3E5FC), const Color(0xFFE1F5FE)];
      case 'mist':
      case 'fog':
      case 'haze': return [const Color(0xFF9E9E9E), const Color(0xFFBDBDBD)];
      default: return [const Color(0xFF1976D2), const Color(0xFF64B5F6)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = _weather;
    final gradient = w != null ? _getGradient(w.main) : [const Color(0xFF1976D2), const Color(0xFF64B5F6)];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: SafeArea(
          child: Column(children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search city...',
                      hintStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white24,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onSubmitted: _fetchByCity,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () => _fetchByCity(_searchCtrl.text),
                ),
                IconButton(
                  icon: const Icon(Icons.my_location, color: Colors.white),
                  onPressed: _fetchByLocation,
                  tooltip: 'Use my location',
                ),
              ]),
            ),

            // Content
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : _error.isNotEmpty
                      ? Center(child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(_error, style: const TextStyle(color: Colors.white, fontSize: 16), textAlign: TextAlign.center),
                        ))
                      : w == null
                          ? const Center(child: Text('Search a city or use your location', style: TextStyle(color: Colors.white70)))
                          : _buildWeatherCard(w),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildWeatherCard(Weather w) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(children: [
        const SizedBox(height: 20),
        // Location
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.location_on, color: Colors.white70, size: 20),
          const SizedBox(width: 4),
          Text('${w.city}, ${w.country}', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 30),
        // Weather icon
        Icon(_getIcon(w.main), size: 100, color: Colors.white),
        const SizedBox(height: 10),
        // Description
        Text(w.description.toUpperCase(), style: const TextStyle(color: Colors.white70, fontSize: 14, letterSpacing: 2)),
        const SizedBox(height: 20),
        // Temperature
        Text('${w.temp.round()}°C', style: const TextStyle(color: Colors.white, fontSize: 72, fontWeight: FontWeight.bold)),
        Text('Feels like ${w.feelsLike.round()}°C', style: const TextStyle(color: Colors.white70, fontSize: 16)),
        const SizedBox(height: 8),
        Text('${w.tempMin.round()}° / ${w.tempMax.round()}°', style: const TextStyle(color: Colors.white60, fontSize: 14)),
        const SizedBox(height: 40),
        // Details row
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _detailTile(Icons.water_drop, '${w.humidity}%', 'Humidity'),
            _detailTile(Icons.air, '${w.windSpeed} m/s', 'Wind'),
          ]),
        ),
        const SizedBox(height: 30),
      ]),
    );
  }

  Widget _detailTile(IconData icon, String value, String label) {
    return Column(children: [
      Icon(icon, color: Colors.white, size: 28),
      const SizedBox(height: 6),
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
    ]);
  }
}
