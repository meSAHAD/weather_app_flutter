import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For day name formatting
import '../models/weather_model.dart';

class ForecastCard extends StatelessWidget {
  final ForecastDay day;

  const ForecastCard({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    // Convert date (e.g. "2025-11-07") to weekday name (e.g. "Friday")
    String dayName = '';
    try {
      final parsedDate = DateFormat('yyyy-MM-dd').parse(day.date);
      dayName = DateFormat('EEEE').format(parsedDate); // e.g. Monday
    } catch (e) {
      dayName = day.date; // fallback if format unknown
    }

    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Day Name (instead of date)
              Text(
                dayName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),

              // Weather Icon
              Image.network(
                day.iconUrl,
                width: 50,
                height: 45,
                errorBuilder: (context, error, stackTrace) => const SizedBox(
                  width: 40,
                  height: 40,
                ),
              ),
              const SizedBox(height: 3),

              // Condition
              Text(
                day.condition,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 3),

              // Temperatures
              Text(
                'Temp: ${day.maxTemp}° / ${day.minTemp}°',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 3),

              // Rain chance
              Text(
                'Rain: ${day.rainChance}%',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
