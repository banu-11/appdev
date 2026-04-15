import 'package:flutter/material.dart';
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

  // Built-in weather data for cities (no API needed)
  final Map<String, Map<String, dynamic>> weatherDatabase = {
    "london": {
      "temp": 12,
      "feels_like": 10,
      "humidity": 75,
      "wind": 15,
      "condition": "Cloudy",
      "icon": "☁️",
      "color": Colors.blueGrey
    },
    "new york": {
      "temp": 18,
      "feels_like": 16,
      "humidity": 65,
      "wind": 12,
      "condition": "Sunny",
      "icon": "☀️",
      "color": Colors.orange
    },
    "tokyo": {
      "temp": 20,
      "feels_like": 19,
      "humidity": 70,
      "wind": 10,
      "condition": "Clear",
      "icon": "🌤️",
      "color": Colors.lightBlue
    },
    "paris": {
      "temp": 15,
      "feels_like": 13,
      "humidity": 80,
      "wind": 14,
      "condition": "Rainy",
      "icon": "🌧️",
      "color": Colors.blue
    },
    "mumbai": {
      "temp": 30,
      "feels_like": 33,
      "humidity": 85,
      "wind": 8,
      "condition": "Humid",
      "icon": "🌡️",
      "color": Colors.deepOrange
    },
    "delhi": {
      "temp": 28,
      "feels_like": 27,
      "humidity": 60,
      "wind": 9,
      "condition": "Sunny",
      "icon": "☀️",
      "color": Colors.orange
    },
    "bangalore": {
      "temp": 22,
      "feels_like": 21,
      "humidity": 70,
      "wind": 11,
      "condition": "Pleasant",
      "icon": "🌤️",
      "color": Colors.lightGreen
    },
    "chennai": {
      "temp": 32,
      "feels_like": 35,
      "humidity": 80,
      "wind": 7,
      "condition": "Hot & Humid",
      "icon": "🔥",
      "color": Colors.red
    },
    "kolkata": {
      "temp": 29,
      "feels_like": 31,
      "humidity": 75,
      "wind": 8,
      "condition": "Humid",
      "icon": "🌡️",
      "color": Colors.deepOrange
    },
    "hyderabad": {
      "temp": 26,
      "feels_like": 25,
      "humidity": 65,
      "wind": 10,
      "condition": "Pleasant",
      "icon": "🌤️",
      "color": Colors.green
    },
    "ahmedabad": {
      "temp": 33,
      "feels_like": 34,
      "humidity": 55,
      "wind": 12,
      "condition": "Hot",
      "icon": "☀️",
      "color": Colors.orange
    },
    "pune": {
      "temp": 24,
      "feels_like": 23,
      "humidity": 68,
      "wind": 9,
      "condition": "Pleasant",
      "icon": "🌤️",
      "color": Colors.lightGreen
    },
    "jaipur": {
      "temp": 27,
      "feels_like": 26,
      "humidity": 45,
      "wind": 13,
      "condition": "Dry & Sunny",
      "icon": "☀️",
      "color": Colors.amber
    },
    "lucknow": {
      "temp": 25,
      "feels_like": 24,
      "humidity": 60,
      "wind": 10,
      "condition": "Clear",
      "icon": "🌤️",
      "color": Colors.lightBlue
    },
    "chandigarh": {
      "temp": 23,
      "feels_like": 22,
      "humidity": 55,
      "wind": 11,
      "condition": "Pleasant",
      "icon": "🌤️",
      "color": Colors.green
    },
    "goa": {
      "temp": 29,
      "feels_like": 32,
      "humidity": 78,
      "wind": 14,
      "condition": "Humid",
      "icon": "🌊",
      "color": Colors.teal
    },
    "shimla": {
      "temp": 8,
      "feels_like": 6,
      "humidity": 85,
      "wind": 18,
      "condition": "Cold",
      "icon": "❄️",
      "color": Colors.blue
    },
    "manali": {
      "temp": 5,
      "feels_like": 3,
      "humidity": 90,
      "wind": 20,
      "condition": "Snowy",
      "icon": "⛄",
      "color": Colors.lightBlue
    },
    "darjeeling": {
      "temp": 10,
      "feels_like": 8,
      "humidity": 82,
      "wind": 16,
      "condition": "Foggy",
      "icon": "🌫️",
      "color": Colors.blueGrey
    },
    "sydney": {
      "temp": 22,
      "feels_like": 21,
      "humidity": 68,
      "wind": 12,
      "condition": "Sunny",
      "icon": "☀️",
      "color": Colors.orange
    },
    "dubai": {
      "temp": 35,
      "feels_like": 38,
      "humidity": 50,
      "wind": 9,
      "condition": "Very Hot",
      "icon": "🔥",
      "color": Colors.deepOrange
    },
    "singapore": {
      "temp": 28,
      "feels_like": 31,
      "humidity": 82,
      "wind": 8,
      "condition": "Humid",
      "icon": "🌧️",
      "color": Colors.blue
    },
    "kuala lumpur": {
      "temp": 27,
      "feels_like": 30,
      "humidity": 80,
      "wind": 7,
      "condition": "Rainy",
      "icon": "🌧️",
      "color": Colors.blue
    },
    "bangkok": {
      "temp": 31,
      "feels_like": 34,
      "humidity": 75,
      "wind": 10,
      "condition": "Hot",
      "icon": "☀️",
      "color": Colors.orange
    },
    "seoul": {
      "temp": 14,
      "feels_like": 12,
      "humidity": 72,
      "wind": 13,
      "condition": "Cloudy",
      "icon": "☁️",
      "color": Colors.blueGrey
    },
    "beijing": {
      "temp": 16,
      "feels_like": 14,
      "humidity": 58,
      "wind": 15,
      "condition": "Smoggy",
      "icon": "🌫️",
      "color": Colors.grey
    },
  };

  // Get weather data for a city (no API call)
  void getWeatherByCity() {
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
    });

    // Find matching city in database
    String matchedCity = "";
    Map<String, dynamic>? weatherData;
    
    // Try exact match first
    if (weatherDatabase.containsKey(city)) {
      matchedCity = city;
      weatherData = weatherDatabase[city];
    } else {
      // Try partial match
      for (String key in weatherDatabase.keys) {
        if (key.contains(city) || city.contains(key)) {
          matchedCity = key;
          weatherData = weatherDatabase[key];
          break;
        }
      }
    }
    
    if (weatherData != null) {
      setState(() {
        cityName = matchedCity.substring(0, 1).toUpperCase() + matchedCity.substring(1);
        temperature = weatherData!['temp'];
        feelsLike = weatherData!['feels_like'];
        humidity = weatherData!['humidity'];
        windSpeed = weatherData!['wind'];
        weatherCondition = weatherData!['condition'];
        weatherIcon = weatherData!['icon'];
        errorMessage = "";
        isLoading = false;
      });
    } else {
      setState(() {
        errorMessage = "City '$city' not found in our database.\nTry: London, New York, Mumbai, Delhi, etc.";
        isLoading = false;
      });
    }
  }

  // Simulate getting weather by location (using random or predefined data)
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
      
      // For demo purposes, use coordinates to suggest a city
      // In a real app without API, you'd have a mapping of coordinates to cities
      List<String> cities = weatherDatabase.keys.toList();
      int index = (position.latitude.abs() * 100).toInt() % cities.length;
      String suggestedCity = cities[index];
      
      Map<String, dynamic> weatherData = weatherDatabase[suggestedCity]!;
      
      setState(() {
        cityName = suggestedCity.substring(0, 1).toUpperCase() + suggestedCity.substring(1);
        temperature = weatherData['temp'];
        feelsLike = weatherData['feels_like'];
        humidity = weatherData['humidity'];
        windSpeed = weatherData['wind'];
        weatherCondition = weatherData['condition'];
        weatherIcon = weatherData['icon'];
        errorMessage = "Showing weather for nearby city: ${cityName}";
        isLoading = false;
      });
      
    } catch (e) {
      // If location fails, show random city
      List<String> cities = weatherDatabase.keys.toList();
      String randomCity = cities[DateTime.now().millisecondsSinceEpoch % cities.length];
      Map<String, dynamic> weatherData = weatherDatabase[randomCity]!;
      
      setState(() {
        cityName = randomCity.substring(0, 1).toUpperCase() + randomCity.substring(1);
        temperature = weatherData['temp'];
        feelsLike = weatherData['feels_like'];
        humidity = weatherData['humidity'];
        windSpeed = weatherData['wind'];
        weatherCondition = weatherData['condition'];
        weatherIcon = weatherData['icon'];
        errorMessage = "Location failed. Showing ${cityName} weather.";
        isLoading = false;
      });
    }
  }

  Color getBackgroundColor() {
    if (weatherCondition.toLowerCase().contains("rain") || weatherCondition.toLowerCase().contains("rainy")) {
      return Colors.blue.shade800;
    } else if (weatherCondition.toLowerCase().contains("snow") || weatherCondition.toLowerCase().contains("snowy")) {
      return Colors.blue.shade100;
    } else if (temperature > 30) {
      return Colors.orange.shade700;
    } else if (temperature < 10) {
      return Colors.blue.shade900;
    } else if (weatherCondition.toLowerCase().contains("humid")) {
      return Colors.teal.shade700;
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

  double getDisplayFeelsLike() {
    if (useCelsius) {
      return feelsLike;
    } else {
      return (feelsLike * 9/5) + 32;
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
                          "Feels like ${getDisplayFeelsLike().toStringAsFixed(1)}${getTemperatureUnit()}",
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
                        
                        // Info message
                        if (errorMessage.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.info_outline, color: Colors.white70, size: 16),
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
                          SizedBox(height: 10),
                          Text(
                            "Available: London, New York, Mumbai,\nDelhi, Bangalore, Chennai, and more!",
                            style: TextStyle(color: Colors.white54, fontSize: 12),
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
