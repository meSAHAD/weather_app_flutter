import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../widgets/forecast_tab_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  Weather? _weather;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchHomeWeather();
  }

  Future<void> _fetchHomeWeather() async {
    if (!mounted) return;
    setState(() => _loading = true);

    String homeCity = 'Barisal'; // Default city
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists && doc.data()!.containsKey('home_city')) {
          homeCity = doc.data()!['home_city'];
        }
      } catch (e) {
        // Could not fetch from Firestore, will use default.
      }
    }

    await _updateWeatherForCity(homeCity);
  }

  Future<void> _updateWeatherForCity(String cityName) async {
    try {
      final weather = await _weatherService.fetchWeather(cityName);
      if (mounted) {
        setState(() {
          _weather = weather;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
      // Optionally show an error if the fetch fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Weather',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_location_alt_outlined,
                color: Colors.white),
            onPressed: _showEditHomeCityDialog,
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/welcome.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.3)),
          _loading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
              : _weather == null
                  ? const Center(
                      child: Text('Failed to load weather',
                          style: TextStyle(color: Colors.white)))
                  : _buildWeatherContent(),
        ],
      ),
    );
  }

  Future<void> _showEditHomeCityDialog() async {
    String? newCity = await showDialog<String>(
      context: context,
      builder: (context) {
        String cityName = '';
        return AlertDialog(
          title: const Text('Set Home City'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter city name'),
            onChanged: (val) => cityName = val,
            onSubmitted: (val) {
              if (val.trim().isNotEmpty) {
                Navigator.pop(context, val.trim());
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (cityName.trim().isNotEmpty) {
                  Navigator.pop(context, cityName.trim());
                }
              },
              child: const Text('Set'),
            ),
          ],
        );
      },
    );

    if (newCity != null) {
      setState(() => _loading = true);

      try {
        // 1. Load the new city's weather and update the UI first.
        await _updateWeatherForCity(newCity);

        // 2. After the UI is updated, save the city to Firebase.
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // This can fail silently or you could add logging.
          // The user's view is already updated, which is the main goal.
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({'home_city': newCity}, SetOptions(merge: true));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not find city: $newCity')),
        );
        // If updating to the new city fails, revert to the previous weather.
        // We set loading to true again because fetchHomeWeather will do it.
        setState(() => _loading = true);
        await _fetchHomeWeather(); // This will handle setting loading to false.
      }
    }
  }

  Widget _buildWeatherContent() {
    final w = _weather!;
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: screenHeight - kToolbarHeight),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Top weather info
              Text(
                w.cityName,
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                '${w.temperature.toStringAsFixed(1)}°',
                style: const TextStyle(
                    fontSize: 90,
                    fontWeight: FontWeight.w200,
                    color: Colors.white),
              ),
              Text(
                w.condition,
                style: const TextStyle(
                    fontSize: 18, color: Colors.white70, letterSpacing: 0.5),
              ),
              const SizedBox(height: 4),
              Text(
                'H: ${w.maxTemp.toStringAsFixed(0)}°  L: ${w.minTemp.toStringAsFixed(0)}°',
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 30),

              // Bottom forecast section
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(40)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    width: double.infinity,
                    color: Colors.white.withOpacity(0.1),
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ForecastTabCard(weather: w),
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
