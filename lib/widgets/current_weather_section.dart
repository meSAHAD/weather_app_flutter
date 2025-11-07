import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class CurrentWeatherSection extends StatelessWidget {
  final Weather weather;

  const CurrentWeatherSection({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(1.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side: City name + Condition
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weather.cityName,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  weather.condition,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),

            // Right side: Temp + Wind + Rain
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '🌡️ ${weather.temperature}°C',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '💨 Wind:${weather.windSpeed} km/h',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '☔ Rain:${weather.rainChance} mm',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
