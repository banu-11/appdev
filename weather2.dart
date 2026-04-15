import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: WeatherPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WeatherPage extends StatefulWidget {
  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  TextEditingController cityController = TextEditingController();
  
  String cityName = "";
  double temperature = 0;
  double feelsLike = 0;
  int humidity = 0;
  double windSpeed = 0;
  String weatherCondition = "";
  String weatherIcon = "☁️";
  String errorMessage = "";
  bool isLoading = false;
  bool useCelsius = true;

  // Fallback weather data for offline mode
  final Map<String, Map<String, dynamic>> fallbackWeather = {
    "london": {
      "temp": 12,
      "feels_like": 10,
      "humidity": 75,
      "wind": 15,
      "condition": "Cloudy",
      "icon": "☁️"
    },
    "new york": {
      "temp": 18,
      "feels_like": 16,
      "humidity": 65,
      "wind": 12,
      "condition": "Sunny",
      "icon": "☀️"
    },
    "tokyo": {
      "temp": 20,
      "feels_like": 19,
      "humidity": 70,
      "wind": 10,
      "condition": "Clear",
      "icon": "🌤️"
    },
    "paris": {
      "temp": 15,
      "feels_like": 13,
      "humidity": 80,
      "wind": 14,
      "condition": "Rainy",
      "icon": "🌧️"
    },
    "mumbai": {
      "temp": 30,
      "feels_like": 33,
      "humidity": 85,
      "wind": 8,
      "condition": "Humid",
      "icon": "🌡️"
    },
    "delhi": {
      "temp": 28,
      "feels_like": 27,
      "humidity": 60,
      "wind": 9,
      "condition": "Sunny",
      "icon": "☀️"
    },
    "bangalore": {
      "temp": 22,
      "feels_like": 21,
      "humidity": 70,
      "wind": 11,
      "condition": "Pleasant",
      "icon": "🌤️"
    },
  };

  // Multiple free weather APIs (no key required)
  final List<Map<String, String>> weatherApis = [
    {
      "name": "OpenMeteo",
      "url": "https://api.open-meteo.com/v1/forecast?latitude={lat}&longitude={lon}&current_weather=true&hourly=temperature_2m,relative_humidity_2m&timezone=auto"
    },
    {
      "name": "Wttr",
      "url": "https://wttr.in/{city}?format=j1"
    }
  ];

  Future<void> getWeatherByCity() async {
    String city = cityController.text.trim().toLowerCase();
    
    if (city.isEmpty) {
      setState(() {
        errorMessage = "Please enter a city name!";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = "";
      cityName = city;
    });

    // Try to fetch from API first
    bool apiSuccess = await fetchWeatherFromApi(city);
    
    // If API fails, use fallback data
    if (!apiSuccess) {
      useFallbackWeather(city);
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> getWeatherByLocation() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      // Check location services
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled. Please enable them.');
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied.');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      // Get city name from coordinates (reverse geocoding)
      bool cityFound = await getCityFromCoordinates(position.latitude, position.longitude);
      
      if (!cityFound) {
        // If can't get city name, use coordinates
        setState(() {
          cityName = "Your Location (${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)})";
        });
        
        // Try to get weather using coordinates
        await fetchWeatherFromCoordinates(position.latitude, position.longitude);
      }
      
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<bool> getCityFromCoordinates(double lat, double lon) async {
    try {
      // Using OpenStreetMap Nominatim API (free, no key)
      final response = await http.get(
        Uri.parse("https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json"),
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['address'] != null) {
          String city = data['address']['city'] ?? 
                       data['address']['town'] ?? 
                       data['address']['village'] ?? 
                       "Your Location";
          setState(() {
            cityName = city;
          });
          await fetchWeatherFromApi(city);
          return true;
        }
      }
    } catch (e) {
      // Continue with coordinates
    }
    return false;
  }

  Future<void> fetchWeatherFromCoordinates(double lat, double lon) async {
    try {
      String url = "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true&hourly=temperature_2m,relative_humidity_2m&timezone=auto";
      
      final response = await http.get(
        Uri.parse(url),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current_weather'];
        final hourly = data['hourly'];
        
        setState(() {
          temperature = current['temperature'];
          windSpeed = current['windspeed'];
          weatherCondition = getWeatherCondition(current['weathercode']);
          weatherIcon = getWeatherIcon(current['weathercode']);
          humidity = hourly['relative_humidity_2m'][0];
          feelsLike = temperature; // OpenMeteo doesn't provide feels like directly
          errorMessage = "";
        });
      } else {
        throw Exception('Failed to fetch weather');
      }
    } catch (e) {
      setState(() {
        errorMessage = "Could not fetch weather for your location. Please search by city name.";
      });
    }
  }

  Future<bool> fetchWeatherFromApi(String city) async {
    // Try OpenMeteo API with geocoding
    try {
      // First, get coordinates for the city (using free geocoding API)
      final geoResponse = await http.get(
        Uri.parse("https://geocoding-api.open-meteo.com/v1/search?name=$city&count=1&language=en&format=json"),
      ).timeout(const Duration(seconds: 5));
      
      if (geoResponse.statusCode == 200) {
        final geoData = json.decode(geoResponse.body);
        if (geoData['results'] != null && geoData['results'].isNotEmpty) {
          double lat = geoData['results'][0]['latitude'];
          double lon = geoData['results'][0]['longitude'];
          String foundCity = geoData['results'][0]['name'];
          
          // Get weather using coordinates
          final weatherResponse = await http.get(
            Uri.parse("https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true&hourly=temperature_2m,relative_humidity_2m&timezone=auto"),
          ).timeout(const Duration(seconds: 5));
          
          if (weatherResponse.statusCode == 200) {
            final weatherData = json.decode(weatherResponse.body);
            final current = weatherData['current_weather'];
            final hourly = weatherData['hourly'];
            
            setState(() {
              cityName = foundCity;
              temperature = current['temperature'];
              windSpeed = current['windspeed'];
              weatherCondition = getWeatherCondition(current['weathercode']);
              weatherIcon = getWeatherIcon(current['weathercode']);
              humidity = hourly['relative_humidity_2m'][0];
              feelsLike = temperature;
              errorMessage = "";
            });
            return true;
          }
        }
      }
    } catch (e) {
      // Try alternative API
      return await fetchFromWttrApi(city);
    }
    return false;
  }

  Future<bool> fetchFromWttrApi(String city) async {
    try {
      final response = await http.get(
        Uri.parse("https://wttr.in/$city?format=j1"),
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current_condition'][0];
        
        setState(() {
          temperature = double.parse(current['temp_C']);
          feelsLike = double.parse(current['FeelsLikeC']);
          humidity = int.parse(current['humidity']);
          windSpeed = double.parse(current['windspeedKmph']);
          weatherCondition = current['weatherDesc'][0]['value'];
          weatherIcon = getWeatherIconFromDesc(weatherCondition);
          errorMessage = "";
        });
        return true;
      }
    } catch (e) {
      // API failed
    }
    return false;
  }

  void useFallbackWeather(String city) {
    String matchedCity = "london";
    
    // Find matching city in fallback data
    for (String key in fallbackWeather.keys) {
      if (city.contains(key) || key.contains(city)) {
        matchedCity = key;
        break;
      }
    }
    
    var weather = fallbackWeather[matchedCity]!;
    
    setState(() {
      cityName = city.substring(0, 1).toUpperCase() + city.substring(1);
      temperature = weather['temp'];
      feelsLike = weather['feels_like'];
      humidity = weather['humidity'];
      windSpeed = weather['wind'];
      weatherCondition = weather['condition'];
      weatherIcon = weather['icon'];
      errorMessage = "Using offline weather data (no internet connection)";
    });
  }

  String getWeatherCondition(int code) {
    switch (code) {
      case 0: return "Clear sky";
      case 1: case 2: case 3: return "Partly cloudy";
      case 45: case 48: return "Foggy";
      case 51: case 53: case 55: return "Drizzle";
      case 61: case 63: case 65: return "Rain";
      case 71: case 73: case 75: return "Snow";
      case 80: case 81: case 82: return "Rain showers";
      case 95: case 96: case 99: return "Thunderstorm";
      default: return "Cloudy";
    }
  }

  String getWeatherIcon(int code) {
    switch (code) {
      case 0: return "☀️";
      case 1: case 2: case 3: return "⛅";
      case 45: case 48: return "🌫️";
      case 51: case 53: case 55: return "🌦️";
      case 61: case 63: case 65: return "🌧️";
      case 71: case 73: case 75: return "❄️";
      case 80: case 81: case 82: return "🌧️";
      case 95: case 96: case 99: return "⛈️";
      default: return "☁️";
    }
  }

  String getWeatherIconFromDesc(String desc) {
    desc = desc.toLowerCase();
    if (desc.contains("sunny") || desc.contains("clear")) return "☀️";
    if (desc.contains("cloud")) return "☁️";
    if (desc.contains("rain")) return "🌧️";
    if (desc.contains("snow")) return "❄️";
    if (desc.contains("thunder")) return "⛈️";
    if (desc.contains("fog")) return "🌫️";
    return "🌡️";
  }

  Color getBackgroundColor() {
    if (weatherCondition.toLowerCase().contains("rain")) {
      return Colors.blue.shade800;
    } else if (weatherCondition.toLowerCase().contains("snow")) {
      return Colors.blue.shade100;
    } else if (temperature > 30) {
      return Colors.orange.shade700;
    } else if (temperature < 10) {
      return Colors.blue.shade900;
    } else {
      return Colors.blue.shade500;
    }
  }

  void toggleTemperatureUnit() {
    setState(() {
      useCelsius = !useCelsius;
    });
  }

  double getDisplayTemperature() {
    if (useCelsius) {
      return temperature;
    } else {
      return (temperature * 9/5) + 32;
    }
  }

  String getTemperatureUnit() {
    return useCelsius ? "°C" : "°F";
  }

  @override
  void dispose() {
    cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [getBackgroundColor(), getBackgroundColor().withOpacity(0.7)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Search Bar
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: cityController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Enter city name...",
                          hintStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(Icons.search, color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white24,
                        ),
                        onSubmitted: (value) => getWeatherByCity(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.my_location, color: Colors.white),
                        onPressed: getWeatherByLocation,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Temperature Unit Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          _buildUnitButton("°C", true),
                          _buildUnitButton("°F", false),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                // Weather Display
                if (isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  )
                else if (errorMessage.isNotEmpty && temperature == 0)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: Colors.white70),
                          const SizedBox(height: 16),
                          Text(
                            errorMessage,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: getWeatherByLocation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blue,
                            ),
                            child: const Text("Use My Location"),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (cityName.isNotEmpty)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // City Name
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on, color: Colors.white70, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              cityName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Weather Icon
                        Text(
                          weatherIcon,
                          style: const TextStyle(fontSize: 80),
                        ),
                        
                        const SizedBox(height: 10),
                        
                        // Weather Condition
                        Text(
                          weatherCondition.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            letterSpacing: 2,
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Temperature
                        Text(
                          "${getDisplayTemperature().toStringAsFixed(1)}${getTemperatureUnit()}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                        const SizedBox(height: 10),
                        
                        Text(
                          "Feels like ${useCelsius ? feelsLike.toStringAsFixed(1) : ((feelsLike * 9/5) + 32).toStringAsFixed(1)}${getTemperatureUnit()}",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Weather Details Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildDetailItem(
                                icon: Icons.water_drop,
                                value: "$humidity%",
                                label: "Humidity",
                              ),
                              _buildDetailItem(
                                icon: Icons.air,
                                value: "${windSpeed.toStringAsFixed(1)} km/h",
                                label: "Wind Speed",
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Offline indicator
                        if (errorMessage.contains("offline"))
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.wifi_off, color: Colors.white70, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  errorMessage,
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  )
                else
                  const Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud, size: 80, color: Colors.white70),
                          SizedBox(height: 20),
                          Text(
                            "Search for a city\nor use your location",
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnitButton(String unit, bool isCelsius) {
    bool isSelected = (isCelsius && useCelsius) || (!isCelsius && !useCelsius);
    return GestureDetector(
      onTap: toggleTemperatureUnit,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          unit,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
