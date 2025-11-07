import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../widgets/forecast_tab_card.dart';
import '../utils/notifiers.dart'; // ✅ add this import

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final WeatherService _weatherService = WeatherService();
  final TextEditingController _controller = TextEditingController();
  Weather? _weather;
  bool _loading = false;
  String? _errorMessage;
  List<String> _recentSearches = [];
  List<String> _savedCities = [];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _loadSavedCities();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recent_cities') ?? [];
    });
  }

  Future<void> _saveRecentSearch(String city) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> updated = [city, ..._recentSearches.where((c) => c != city)];
    if (updated.length > 5) updated = updated.sublist(0, 5); // keep 5 max
    await prefs.setStringList('recent_cities', updated);
    setState(() {
      _recentSearches = updated;
    });
  }

  Future<void> _loadSavedCities() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedCities = prefs.getStringList('saved_cities') ?? [];
    });
  }

  Future<void> _addToCities(String city) async {
    final prefs = await SharedPreferences.getInstance();
    if (!_savedCities.contains(city)) {
      setState(() {
        _savedCities.add(city);
      });
      await prefs.setStringList('saved_cities', _savedCities);

      // ✅ Notify Cities tab to refresh
      citiesUpdatedNotifier.value = true;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$city added to Cities tab!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_cities');
    setState(() {
      _recentSearches = [];
    });
  }

  Future<void> _searchCity(String cityName) async {
    if (cityName.isEmpty) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final weather = await _weatherService.fetchWeather(cityName);
      setState(() {
        _weather = weather;
        _loading = false;
      });
      _saveRecentSearch(cityName);
    } catch (e) {
      setState(() {
        _errorMessage = 'City not found. Try again.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search City Weather'),
        centerTitle: true,
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
          Container(color: Colors.black.withOpacity(0.4)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 12),
                  if (_recentSearches.isNotEmpty) _buildRecentSearches(),
                  const SizedBox(height: 16),
                  Expanded(child: _buildBody()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _controller,
      textInputAction: TextInputAction.search,
      onSubmitted: _searchCity,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Enter city name...',
        hintStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.black26,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () => _searchCity(_controller.text.trim()),
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Recent searches:',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _clearRecentSearches,
              icon: const Icon(Icons.delete_outline,
                  color: Colors.white70, size: 18),
              label: const Text('Clear All',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _recentSearches
              .map((city) => ActionChip(
                    label: Text(city),
                    backgroundColor: Colors.white.withOpacity(0.8),
                    onPressed: () => _searchCity(city),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    }
    if (_errorMessage != null) {
      return Center(
        child: Text(_errorMessage!,
            style: const TextStyle(color: Colors.white, fontSize: 16)),
      );
    }
    if (_weather == null) {
      return const Center(
        child: Text(
          'Search for a city to view weather.',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    final w = _weather!;
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            w.cityName,
            style: const TextStyle(
                fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            w.condition,
            style: const TextStyle(fontSize: 18, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            '${w.temperature.toStringAsFixed(1)}°C',
            style: const TextStyle(
                fontSize: 42, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _infoItem('💨 Wind', '${w.windSpeed} km/h'),
              _infoItem('☔ Rain', '${w.rainChance}%'),
            ],
          ),
          const SizedBox(height: 16),
          ForecastTabCard(weather: w),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () => _addToCities(w.cityName),
            icon: const Icon(Icons.add_location_alt_outlined),
            label: const Text('Add to Cities'),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
      ],
    );
  }
}
