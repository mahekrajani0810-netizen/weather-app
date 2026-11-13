import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController cityController = TextEditingController(
    text: 'Rajkot',
  );

  // Paste your NEW API key here
  const String apiKey = String.fromEnvironment('OPENWEATHER_API_KEY');
  Map<String, dynamic>? weatherData;

  bool isLoading = false;
  String errorMessage = '';

  Future<void> getWeather(String city) async {
    if (city.trim().isEmpty) {
      setState(() {
        errorMessage = 'Please enter a city name.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
      weatherData = null;
    });

    try {
      final url = Uri.https('api.openweathermap.org', '/data/2.5/weather', {
        'q': city.trim(),
        'appid': apiKey,
        'units': 'metric',
      });

      final response = await http.get(url);

      debugPrint('Status: ${response.statusCode}');
      debugPrint('Response: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          weatherData = jsonDecode(response.body);
        });
      } else {
        setState(() {
          errorMessage = 'City not found or API error. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Please check your internet connection.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  IconData getWeatherIcon() {
    if (weatherData == null) {
      return Icons.cloud;
    }

    String condition = weatherData!['weather'][0]['main']
        .toString()
        .toLowerCase();

    if (condition.contains('clear')) {
      return Icons.wb_sunny_rounded;
    } else if (condition.contains('cloud')) {
      return Icons.cloud_rounded;
    } else if (condition.contains('rain')) {
      return Icons.water_drop_rounded;
    } else if (condition.contains('thunderstorm')) {
      return Icons.thunderstorm_rounded;
    } else if (condition.contains('snow')) {
      return Icons.ac_unit_rounded;
    } else if (condition.contains('mist') || condition.contains('fog')) {
      return Icons.cloud_rounded;
    }

    return Icons.wb_cloudy_rounded;
  }

  @override
  void initState() {
    super.initState();
    getWeather('Rajkot');
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF101B3D), Color(0xFF172E58), Color(0xFF091426)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 15),

                // APP TITLE
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud, color: Colors.lightBlueAccent, size: 35),
                    SizedBox(width: 10),
                    Text(
                      'Weather App',
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // SEARCH BAR
                TextField(
                  controller: cityController,
                  style: const TextStyle(color: Colors.white, fontSize: 16),

                  decoration: InputDecoration(
                    hintText: 'Search your city...',
                    hintStyle: const TextStyle(color: Colors.white54),

                    prefixIcon: const Icon(Icons.search, color: Colors.white70),

                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        getWeather(cityController.text);
                      },
                    ),

                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.12),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),

                  onSubmitted: (value) {
                    getWeather(value);
                  },
                ),

                const SizedBox(height: 35),

                // LOADING
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.all(30),
                    child: CircularProgressIndicator(color: Colors.white),
                  ),

                // ERROR MESSAGE
                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 16,
                      ),
                    ),
                  ),

                // WEATHER INFORMATION
                if (weatherData != null && !isLoading) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.lightBlueAccent,
                        size: 22,
                      ),
                      const SizedBox(width: 5),

                      Text(
                        '${weatherData!['name']}, ${weatherData!['sys']['country']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 35),

                  // WEATHER ICON
                  Icon(getWeatherIcon(), size: 125, color: Colors.orangeAccent),

                  const SizedBox(height: 15),

                  // TEMPERATURE
                  Text(
                    '${weatherData!['main']['temp'].round()}°C',
                    style: const TextStyle(
                      fontSize: 75,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    weatherData!['weather'][0]['description']
                        .toString()
                        .toUpperCase(),
                    style: const TextStyle(
                      fontSize: 17,
                      color: Colors.white70,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // WEATHER DETAILS TITLE
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Weather Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // WEATHER CARDS
                  Row(
                    children: [
                      Expanded(
                        child: weatherCard(
                          Icons.water_drop_rounded,
                          'Humidity',
                          '${weatherData!['main']['humidity']}%',
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: weatherCard(
                          Icons.air_rounded,
                          'Wind Speed',
                          '${weatherData!['wind']['speed']} m/s',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                        child: weatherCard(
                          Icons.thermostat_rounded,
                          'Feels Like',
                          '${weatherData!['main']['feels_like'].round()}°C',
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: weatherCard(
                          Icons.compress_rounded,
                          'Pressure',
                          '${weatherData!['main']['pressure']} hPa',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    'Weather data powered by OpenWeather',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // WEATHER CARD DESIGN

  Widget weatherCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 10),

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),

      child: Column(
        children: [
          Icon(icon, color: Colors.lightBlueAccent, size: 35),

          const SizedBox(height: 12),

          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),

          const SizedBox(height: 8),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
