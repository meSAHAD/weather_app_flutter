import 'package:flutter/material.dart';
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
                setState(() => _cityNames.add(cityName));
                _saveCities();
                await _fetchCitiesWeather();
                if (mounted) Navigator.pop(context);
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        title: const Text('Cities'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(_isEditMode ? Icons.done : Icons.edit),
            onPressed: () => setState(() => _isEditMode = !_isEditMode),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF87CEFA),
              Color(0xFFE0F7FA)
            ], // light blue gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ReorderableListView.builder(
                padding:
                    const EdgeInsets.symmetric(vertical: 80, horizontal: 12),
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
                  return Container(
                    key: ValueKey('${weather.cityName}_$index'), // ✅ unique key
                    child: _buildCityCard(weather, index, isDragging),
                  );
                },
              ),
      ),
      floatingActionButton: !_isEditMode
          ? FloatingActionButton(
              onPressed: _showAddCityDialog,
              backgroundColor: Colors.teal,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildCityCard(Weather weather, int index, bool isDragging) {
    return Dismissible(
      key: Key('${weather.cityName}_$index'),
      direction:
          _isEditMode ? DismissDirection.endToStart : DismissDirection.none,
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
        color: Colors.redAccent,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: isDragging ? 1.05 : 1.0,
        child: Card(
          elevation: 6,
          shadowColor: Colors.black26,
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white.withOpacity(0.9),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            title: Text(
              weather.cityName,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            subtitle: Text(
              "${weather.temperature.toStringAsFixed(1)}°C  |  ${weather.condition}",
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
            trailing: _isEditMode
                ? ReorderableDragStartListener(
                    index: index,
                    child: const Icon(Icons.reorder, color: Colors.black45),
                  )
                : null,
            onTap: () {
              if (!_isEditMode) _showExpandedWeather(weather);
            },
          ),
        ),
      ),
    );
  }
}
