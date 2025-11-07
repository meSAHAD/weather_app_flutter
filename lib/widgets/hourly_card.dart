import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import 'package:intl/intl.dart'; 

class HourlyCard extends StatelessWidget {
  final HourlyForecast hour;

  const HourlyCard({super.key, required this.hour});

  @override
  Widget build(BuildContext context) {
    final dateTime = DateFormat("yyyy-MM-dd HH:mm").parse(hour.time);
    final timeLabel = DateFormat("hh:mm a").format(dateTime); 

    return Container(
      width: 120,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        color: Colors.white, // solid white color
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                timeLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Image.network(hour.iconUrl, width: 50, height: 45),
              const SizedBox(height: 6),
              Text(
                '${hour.temp}°C',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '☔ ${hour.chanceOfRain}%',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
