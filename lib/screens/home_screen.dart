import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../widgets/forecast_tab_card.dart';
import '../utils/weather_background.dart';

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
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5B86E5), Color(0xFF36D1DC)],
          )
        : WeatherBackground.getGradient(_weather!.condition);

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
      ),
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white))
            : _weather == null
                ? const Center(
                    child: Text('Failed to load weather',
                        style: TextStyle(color: Colors.white)))
                : _buildWeatherContent(),
      ),
    );
  }

  Widget _buildWeatherContent() {
    final w = _weather!;
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: screenHeight),
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
                '${w.temperature?.toStringAsFixed(1) ?? '--'}°',
                style: const TextStyle(
                    fontSize: 90,
                    fontWeight: FontWeight.w200,
                    color: Colors.white),
              ),
              Text(
                '${w.condition}',
                style: const TextStyle(
                    fontSize: 18, color: Colors.white70, letterSpacing: 0.5),
              ),
              const SizedBox(height: 4),
              Text(
                'H: ${w.maxTemp?.toStringAsFixed(0) ?? '--'}°  L: ${w.minTemp?.toStringAsFixed(0) ?? '--'}°',
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
                    color: Colors.white.withOpacity(0.2),
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      children: [
                        _buildForecastTabs(),
                        const SizedBox(height: 8),
                        ForecastTabCard(weather: w),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForecastTabs() {
    return DefaultTabController(
      length: 3,
      child: TabBar(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
        tabs: const [
          Tab(text: 'Today'),
          Tab(text: 'Tomorrow'),
          Tab(text: 'Next 7 Days'),
        ],
      ),
    );
  }
}
