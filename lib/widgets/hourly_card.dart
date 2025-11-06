import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class HourlyCard extends StatelessWidget {
  final HourlyForecast hour;

  const HourlyCard({super.key, required this.hour});

  @override
  Widget build(BuildContext context) {
    final timeLabel = hour.time.split(' ').last; // e.g. "14:00"
    return Container(
      width: 90,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Card(
        color: Colors.white.withOpacity(0.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(timeLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Image.network(hour.iconUrl, width: 40, height: 40),
              Text('${hour.temp}°C'),
              Text('☔ ${hour.chanceOfRain}%',
                  style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
