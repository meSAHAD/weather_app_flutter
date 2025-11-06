import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import 'city_weather_card.dart';

class OtherCitiesSection extends StatelessWidget {
  final List<Weather> otherCities;
  final void Function(Weather) onCityTap;

  const OtherCitiesSection({
    super.key,
    required this.otherCities,
    required this.onCityTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weather in Other Cities',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: otherCities.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: otherCities.length,
                  itemBuilder: (context, index) {
                    final cityWeather = otherCities[index];
                    return AnimatedScale(
                      duration: const Duration(milliseconds: 150),
                      scale: 1.0,
                      child: CityWeatherCard(
                        weather: cityWeather,
                        onTap: () => onCityTap(cityWeather),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
