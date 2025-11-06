import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../widgets/current_weather_section.dart';
import '../widgets/hourly_forecast_section.dart';
import '../widgets/weekly_forecast_section.dart';
import '../widgets/other_cities_section.dart';
import '../utils/weather_background.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();
  final TextEditingController _cityController = TextEditingController();

  Weather? _weather;
  bool _loading = false;
  bool _fading = false;

  List<String> _cityNames = ['Dhaka', 'Chittagong', 'Khulna','Rajshahi', 'Sylhet', 'Barisal', 'Rangpur', 'Mymensingh'];
  List<Weather> _otherCities = [];

  @override
  void initState() {
    super.initState();
    _loadInitialWeather();
  }

  Future<void> _loadInitialWeather() async {
    _cityController.text = 'Barisal';
    await _getWeather('Barisal', animate: false);
    await _loadOtherCitiesWeather();
  }

  Future<void> _getWeather(String cityName, {bool animate = true}) async {
    setState(() {
      _loading = true;
      if (animate) _fading = true;
    });

    try {
      final weather = await _weatherService.fetchWeather(cityName);
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        _weather = weather;
        _fading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('City not found or network error')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadOtherCitiesWeather() async {
    List<Weather> results = [];
    for (var city in _cityNames) {
      try {
        final data = await _weatherService.fetchWeather(city);
        results.add(data);
      } catch (_) {}
    }
    setState(() => _otherCities = results);
  }

  Future<void> _swapCity(Weather clickedCity) async {
    if (_weather == null) return;

    final currentMain = _weather!;
    final index =
        _otherCities.indexWhere((c) => c.cityName == clickedCity.cityName);
    if (index == -1) return;

    setState(() {
      _otherCities[index] = currentMain;
      _cityController.text = clickedCity.cityName;
    });

    await _getWeather(clickedCity.cityName);
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _weather == null
        ? const LinearGradient(
            colors: [Colors.blueGrey, Colors.lightBlueAccent])
        : WeatherBackground.getGradient(_weather!.condition);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                  labelText: 'Enter city name',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => _getWeather(_cityController.text),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              if (_loading && _weather == null)
                const Center(
                    child: CircularProgressIndicator(color: Colors.white))
              else if (_weather != null)
                Expanded(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: _fading ? 0 : 1,
                    child: ListView(
                      children: [
                        CurrentWeatherSection(weather: _weather!),
                        const SizedBox(height: 20),
                        HourlyForecastSection(hourly: _weather!.hourly),
                        const SizedBox(height: 20),
                        WeeklyForecastSection(forecast: _weather!.forecast),
                        const SizedBox(height: 25),
                        OtherCitiesSection(
                          otherCities: _otherCities,
                          onCityTap: _swapCity,
                        ),
                      ],
                    ),
                  ),
                )
              else
                const Center(
                  child: Text(
                    'Unable to load weather data.',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
