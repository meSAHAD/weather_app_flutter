import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import 'hourly_card.dart';

class HourlyForecastSection extends StatelessWidget {
  final List<HourlyForecast> hourly;

  const HourlyForecastSection({super.key, required this.hourly});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hourly Forecast (Today)',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 12),
        hourly.isEmpty
            ? const Center(
                child: Text('No hourly data available',
                    style: TextStyle(color: Colors.white)),
              )
            : SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: hourly.length,
                  itemBuilder: (context, index) =>
                      HourlyCard(hour: hourly[index]),
                ),
              ),
      ],
    );
  }
}
