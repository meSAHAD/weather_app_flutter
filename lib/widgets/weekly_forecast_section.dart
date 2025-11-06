import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import 'forecast_card.dart';

class WeeklyForecastSection extends StatelessWidget {
  final List<ForecastDay> forecast;

  const WeeklyForecastSection({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '7-Day Forecast',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: forecast.length,
            itemBuilder: (context, index) => ForecastCard(day: forecast[index]),
          ),
        ),
      ],
    );
  }
}
