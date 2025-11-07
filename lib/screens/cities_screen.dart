import 'package:flutter/material.dart';
import 'dart:ui'; // Import for ImageFilter
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../utils/notifiers.dart';
import '../widgets/expandable_city_card.dart';

class CitiesScreen extends StatefulWidget {
  const CitiesScreen({super.key});

  @override
  State<CitiesScreen> createState() => _CitiesScreenState();
}

class _CitiesScreenState extends State<CitiesScreen> {
  final WeatherService _weatherService = WeatherService();
  List<String> _cityNames = [];
  List<Weather> _citiesWeather = [];
  bool _loading = true;
  bool _isEditMode = false;
  int? _draggingIndex;

  @override
  void initState() {
    super.initState();
    _loadCities();

    citiesUpdatedNotifier.addListener(() {
      if (citiesUpdatedNotifier.value == true) {
        _loadCities();
        citiesUpdatedNotifier.value = false;
      }
    });
  }

  Future<void> _loadCities() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('saved_cities') ??
        ['Dhaka', 'Chittagong', 'Khulna'];
    _cityNames = saved;
    await _fetchCitiesWeather();
  }

  Future<void> _fetchCitiesWeather() async {
    setState(() => _loading = true);
    _citiesWeather.clear();
    for (final city in _cityNames) {
      try {
        final weather = await _weatherService.fetchWeather(city);
        _citiesWeather.add(weather);
      } catch (e) {
        debugPrint('Error fetching weather for $city: $e');
      }
    }
    setState(() => _loading = false);
  }

  Future<void> _saveCities() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('saved_cities', _cityNames);
  }

  void _showExpandedWeather(Weather weather) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExpandableCityCard(weather: weather),
    );
  }

  void _showAddCityDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String cityName = '';
        return AlertDialog(
          backgroundColor: Colors.white,
          title:
              const Text('Add City', style: TextStyle(color: Colors.black87)),
          content: TextField(
            style: const TextStyle(color: Colors.black87),
            decoration: const InputDecoration(
              hintText: 'Enter city name',
              hintStyle: TextStyle(color: Colors.black54),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.teal),
              ),
            ),
            onChanged: (val) => cityName = val,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.black54)),
            ),
            TextButton(
              onPressed: () async {
                if (cityName.trim().isEmpty) return;

                final alreadyExists = _cityNames.any((c) =>
                    c.toLowerCase().trim() == cityName.toLowerCase().trim());
                if (alreadyExists) {
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '$cityName is already added.',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.redAccent,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                  return;
                }

                if (mounted) Navigator.pop(context);

                // Fetch weather for the new city and add it
                try {
                  final weather =
                      await _weatherService.fetchWeather(cityName.trim());
                  setState(() {
                    _cityNames.add(cityName.trim());
                    _citiesWeather.add(weather);
                    _saveCities();
                  });
                } catch (e) {
                  debugPrint(
                      'Error fetching weather for new city $cityName: $e');
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Could not find weather for $cityName')));
                }
              },
              child: const Text('Add', style: TextStyle(color: Colors.teal)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const gradient = LinearGradient(
      colors: [Colors.indigo, Colors.blueAccent],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        title: const Text('Cities',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white54,
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditMode)
            IconButton(
              icon: const Icon(Icons.add, color: Colors.black),
              tooltip: 'Add City',
              onPressed: _showAddCityDialog,
            ),
          IconButton(
            icon: _loading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : const Icon(Icons.refresh, color: Colors.black),
            tooltip: 'Refresh Weather',
            onPressed: _loading
                ? null
                : () async {
                    await _fetchCitiesWeather();

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Weather updated successfully!',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
          ),
          IconButton(
            icon: Icon(
              _isEditMode ? Icons.done : Icons.edit,
              color: Colors.black,
            ),
            tooltip: _isEditMode ? 'Done Editing' : 'Edit Cities',
            onPressed: () => setState(() => _isEditMode = !_isEditMode),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: gradient),
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white))
            : ReorderableListView.builder(
                // Add padding to avoid content being hidden by the nav bar
                padding: const EdgeInsets.only(
                  top: 16,
                  left: 12,
                  right: 12,
                  bottom: 120, // Space for the floating navigation bar
                ),
                itemCount: _citiesWeather.length,
                onReorderStart: (index) =>
                    setState(() => _draggingIndex = index),
                onReorderEnd: (_) => setState(() => _draggingIndex = null),
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex -= 1;
                    final city = _cityNames.removeAt(oldIndex);
                    final weather = _citiesWeather.removeAt(oldIndex);
                    _cityNames.insert(newIndex, city);
                    _citiesWeather.insert(newIndex, weather);
                  });
                  _saveCities();
                },
                buildDefaultDragHandles: false,
                itemBuilder: (context, index) {
                  final weather = _citiesWeather[index];
                  final isDragging = _draggingIndex == index;
                  return _buildCityCard(weather, index, isDragging);
                },
              ),
      ),
      floatingActionButton: null,
    );
  }

  Widget _buildCityCard(Weather weather, int index, bool isDragging) {
    final cardContent = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // LEFT: City name & condition
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                weather.cityName,
                style: const TextStyle(
                  color: Colors.black87,
                  // color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                weather.condition,
                style: const TextStyle(color: Colors.black54, fontSize: 14),
                // style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),

          // RIGHT: Icon, Temp, Wind
          Row(
            children: [
              Image.network(
                weather.iconUrl,
                width: 50,
                height: 50,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.cloud, size: 40, color: Colors.white70),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${weather.temperature.toStringAsFixed(1)}°C",
                    style: const TextStyle(
                      color: Colors.black,
                      // color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.air_rounded,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        "${weather.windSpeed.toStringAsFixed(1)} km/h",
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 13),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );

    final decoratedCard = AnimatedScale(
      key: ValueKey(weather.cityName),
      duration: const Duration(milliseconds: 200),
      scale: isDragging ? 1.05 : 1.0,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: !_isEditMode ? () => _showExpandedWeather(weather) : null,
          child: cardContent,
        ),
      ),
    );

    if (_isEditMode) {
      return Dismissible(
        key: ValueKey('dismissible_${weather.cityName}'),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          setState(() {
            _cityNames.removeAt(index);
            _citiesWeather.removeAt(index);
            _saveCities();
          });
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        child: Stack(
          children: [
            decoratedCard,
            Positioned(
              right: 8,
              top: 8,
              child: ReorderableDragStartListener(
                index: index,
                child: const Icon(Icons.reorder, color: Colors.white70),
              ),
            ),
          ],
        ),
      );
    } else {
      return decoratedCard;
    }
  }
}
