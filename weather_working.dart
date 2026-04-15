import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  double temp = 0;
  String city = "";
  String condition = "";
  String icon = "";

  final List<String> cities = [
    "Chennai",
    "Delhi",
    "Mumbai",
    "Bangalore",
    "Hyderabad"
  ];

  final List<String> weatherList = [
    "Clear",
    "Clouds",
    "Rain",
    "Thunderstorm",
    "Drizzle",
    "Snow"
  ];

  @override
  void initState() {
    super.initState();
    getRandomWeather();
  }

  void getRandomWeather() {
    final random = Random();

    setState(() {
      temp = 20 + random.nextInt(15) + random.nextDouble();
      city = cities[random.nextInt(cities.length)];
      condition = weatherList[random.nextInt(weatherList.length)];
      icon = getWeatherIcon(condition);
    });
  }

  String getWeatherIcon(String condition) {
    switch (condition) {
      case "Clear":
        return "☀️";
      case "Clouds":
        return "☁️";
      case "Rain":
        return "🌧️";
      case "Thunderstorm":
        return "⛈️";
      case "Drizzle":
        return "🌦️";
      case "Snow":
        return "❄️";
      default:
        return "🌈";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      body: Center(
        child: city.isEmpty
            ? CircularProgressIndicator(color: Colors.white)
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: TextStyle(fontSize: 80)),
            SizedBox(height: 10),
            Text(
              "${temp.toStringAsFixed(1)}°C",
              style: TextStyle(fontSize: 50, color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              city,
              style: TextStyle(fontSize: 30, color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              condition,
              style: TextStyle(fontSize: 20, color: Colors.white70),
            ),
            SizedBox(height: 30),

            // 🔄 Refresh Button
            ElevatedButton.icon(
              onPressed: getRandomWeather,
              icon: Icon(Icons.refresh),
              label: Text("Refresh Weather"),
              style: ElevatedButton.styleFrom(
                padding:
                EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
