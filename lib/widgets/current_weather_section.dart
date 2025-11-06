import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class CurrentWeatherSection extends StatelessWidget {
  final Weather weather;

  const CurrentWeatherSection({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              weather.cityName,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              weather.condition,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text('🌡️ Temp: ${weather.temperature}°C'),
            Text('💨 Wind: ${weather.windSpeed} km/h'),
            Text('☔ Rain: ${weather.rainChance} mm'),
          ],
        ),
      ),
    );
  }
}
