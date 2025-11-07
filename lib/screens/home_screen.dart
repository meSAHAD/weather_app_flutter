import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../utils/weather_background.dart';
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
    _fetchBarisalWeather();
  }

  Future<void> _fetchBarisalWeather() async {
    try {
      final weather = await _weatherService.fetchWeather('Barisal');
      setState(() {
        _weather = weather;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _weather == null
        ? const LinearGradient(
            colors: [Colors.blueGrey, Colors.lightBlueAccent])
        : WeatherBackground.getGradient(_weather!.condition);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather - Barisal'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white))
            : _weather == null
                ? const Center(
                    child: Text('Failed to load weather',
                        style: TextStyle(color: Colors.white)))
                : ListView(
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Text(
                              _weather!.cityName,
                              style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _weather!.condition,
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.white70),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_weather!.temperature.toStringAsFixed(1)}°C',
                              style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _infoItem(
                                    '💨 Wind', '${_weather!.windSpeed} km/h'),
                                _infoItem('☁️ Clouds', _weather!.condition),
                                _infoItem('☔ Rain', '${_weather!.rainChance}%'),
                              ],
                            ),
                            const SizedBox(height: 20),
                            ForecastTabCard(weather: _weather!),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
