import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class CityWeatherCard extends StatelessWidget {
  final Weather weather;
  final VoidCallback onTap;

  const CityWeatherCard({
    super.key,
    required this.weather,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Card(
          color: Colors.white.withOpacity(0.9),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  weather.cityName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Image.network(
                  weather.forecast.isNotEmpty
                      ? weather.forecast[0].iconUrl
                      : 'https://cdn.weatherapi.com/weather/64x64/day/113.png',
                  width: 48,
                  height: 48,
                ),
                const SizedBox(height: 8),
                Text('${weather.temperature.toStringAsFixed(1)}°C',
                    style: const TextStyle(fontSize: 16)),
                Text(weather.condition,
                    style:
                        const TextStyle(fontSize: 14, color: Colors.black54)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
