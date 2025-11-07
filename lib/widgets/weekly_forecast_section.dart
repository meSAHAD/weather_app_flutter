import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import 'package:intl/intl.dart';

class WeeklyForecastTab extends StatelessWidget {
  final List<ForecastDay> forecast;

  const WeeklyForecastTab({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    if (forecast.isEmpty) {
      return const Center(
        child: Text(
          'No forecast data available',
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: forecast.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final f = forecast[index];

        // Parse date and get weekday name
        String dayName;
        try {
          final date = DateFormat('yyyy-MM-dd').parse(f.date);
          dayName = DateFormat('EEE').format(date); // Mon, Tue, Wed, etc.
        } catch (_) {
          dayName = f.date;
        }

        final isToday = f.date == today;

        return Container(
          decoration: BoxDecoration(
            color: isToday ? Colors.teal.withOpacity(0.9) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.network(
                    f.iconUrl,
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isToday ? 'Today' : dayName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isToday ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        f.condition,
                        style: TextStyle(
                          fontSize: 13,
                          color: isToday
                              ? Colors.white70
                              : Colors.blueGrey.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${f.maxTemp.toStringAsFixed(0)}° / ${f.minTemp.toStringAsFixed(0)}°',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isToday ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    '${f.rainChance.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: isToday ? Colors.white70 : Colors.blueGrey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
