import 'package:flutter/material.dart';
import 'dart:ui';
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

  static const double _expandedHeaderHeight = 180.0;

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
        ['Dhaka', 'Chittagong', 'Khulna', 'Rajshahi', 'Sylhet'];
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
      } catch (_) {}
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
      builder: (_) => ExpandableCityCard(weather: weather),
    );
  }

  void _showAddCityDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String cityName = '';
        return AlertDialog(
          title: const Text('Add City'),
          content: TextField(
            decoration: const InputDecoration(hintText: 'Enter city name'),
            onChanged: (val) => cityName = val,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (cityName.trim().isEmpty) return;
                Navigator.pop(context);

                try {
                  final weather =
                      await _weatherService.fetchWeather(cityName.trim());
                  setState(() {
                    _cityNames.add(cityName.trim());
                    _citiesWeather.add(weather);
                    _saveCities();
                  });
                } catch (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('City not found: $cityName')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/welcome.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
          child: SafeArea(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white))
                : CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        backgroundColor: Colors.transparent,
                        expandedHeight: _expandedHeaderHeight,
                        pinned: true,
                        elevation: 0,
                        automaticallyImplyLeading: false,
                        flexibleSpace: LayoutBuilder(
                          builder: (context, constraints) {
                            final maxH = _expandedHeaderHeight;
                            final minH = kToolbarHeight;
                            double frac =
                                (constraints.maxHeight - minH) / (maxH - minH);
                            frac = frac.clamp(0.0, 1.0);

                            // Animation & positioning
                            final titleAlignment = Alignment(
                                lerpDouble(-0.0, -0.9, 1 - frac)!, 0.0);
                            final buttonsAlignment =
                                Alignment(lerpDouble(0.0, 0.9, 1 - frac)!, 0.0);
                            final titleScale = lerpDouble(1.0, 0.58, 1 - frac)!;

                            final bgOpacity = lerpDouble(0.0, 0.4, 1 - frac)!;

                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                // Black background overlay (whole section)
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  color: Colors.black26.withOpacity(bgOpacity),
                                ),

                                // Title
                                AnimatedAlign(
                                  duration: const Duration(milliseconds: 150),
                                  alignment: titleAlignment,
                                  curve: Curves.easeOut,
                                  child: Transform.scale(
                                    scale: titleScale,
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        left: 16 * (1 - frac),
                                        top: frac > 0.6 ? 12 : 0,
                                      ),
                                      child: Text(
                                        'MY CITIES',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 38,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black
                                                  .withOpacity(0.35),
                                              offset: const Offset(0, 2),
                                              blurRadius: 6,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Buttons
                                AnimatedAlign(
                                  duration: const Duration(milliseconds: 150),
                                  alignment: buttonsAlignment,
                                  curve: Curves.easeOut,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      right: 8,
                                      top: frac > 0.6 ? 80 : 8,
                                      left: 12,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (!_isEditMode)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4),
                                            child: TextButton.icon(
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.white,
                                              ),
                                              onPressed: _showAddCityDialog,
                                              icon: const Icon(Icons.add),
                                              label: const Text('Add City'),
                                            ),
                                          ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4),
                                          child: TextButton.icon(
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.white,
                                            ),
                                            onPressed: _fetchCitiesWeather,
                                            icon: const Icon(Icons.refresh),
                                            label: const Text('Refresh'),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4),
                                          child: TextButton.icon(
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.white,
                                            ),
                                            onPressed: () => setState(() =>
                                                _isEditMode = !_isEditMode),
                                            icon: Icon(
                                              _isEditMode
                                                  ? Icons.done
                                                  : Icons.edit,
                                            ),
                                            label: Text(
                                                _isEditMode ? 'Done' : 'Edit'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      // --- City Cards
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        sliver: SliverToBoxAdapter(
                          child: ReorderableListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _citiesWeather.length,
                            onReorder: (oldIndex, newIndex) {
                              setState(() {
                                if (newIndex > oldIndex) newIndex -= 1;
                                final city = _cityNames.removeAt(oldIndex);
                                final weather =
                                    _citiesWeather.removeAt(oldIndex);
                                _cityNames.insert(newIndex, city);
                                _citiesWeather.insert(newIndex, weather);
                              });
                              _saveCities();
                            },
                            buildDefaultDragHandles: false,
                            itemBuilder: (context, index) {
                              final weather = _citiesWeather[index];
                              return _buildCityCard(weather, index);
                            },
                          ),
                        ),
                      ),

                      SliverToBoxAdapter(child: SizedBox(height: 100)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildCityCard(Weather weather, int index) {
    final card = Container(
      key: ValueKey(weather.cityName),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: !_isEditMode ? () => _showExpandedWeather(weather) : null,
        title: Text(
          weather.cityName,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(weather.condition,
            style: const TextStyle(color: Colors.white70)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${weather.temperature.toStringAsFixed(1)}°C",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            if (_isEditMode) const SizedBox(width: 8),
            if (_isEditMode)
              ReorderableDragStartListener(
                index: index,
                child:
                    const Icon(Icons.reorder, color: Colors.white70, size: 22),
              ),
          ],
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
        child: card,
      );
    } else {
      return card;
    }
  }
}
