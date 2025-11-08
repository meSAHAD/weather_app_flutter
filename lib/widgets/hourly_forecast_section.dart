import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import 'package:intl/intl.dart';

class HourlyForecastTab extends StatelessWidget {
  final List<HourlyForecast> hourly;
  final bool isTransparent;

  const HourlyForecastTab({
    super.key,
    required this.hourly,
    this.isTransparent = false,
  });

  @override
  Widget build(BuildContext context) {
    if (hourly.isEmpty) {
      return Center(
        child: Text(
          'No hourly data available',
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    final now = DateTime.now();

    // 🔹 Only include current and future hours
    final filtered = hourly.where((h) {
      try {
        final hourTime = DateFormat('yyyy-MM-dd HH:mm').parse(h.time);
        return !hourTime.isBefore(now.subtract(const Duration(minutes: 59)));
      } catch (_) {
        return false;
      }
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'No upcoming hourly data available',
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final h = filtered[index];

        late final DateTime hourTime;
        try {
          hourTime = DateFormat('yyyy-MM-dd HH:mm').parse(h.time);
        } catch (_) {
          return const SizedBox.shrink();
        }

        final difference = now.difference(hourTime).inMinutes;
        final isNow = difference >= 0 && difference < 60;

        // 🔹 Format time in 12-hour style
        String displayTime;
        try {
          displayTime = DateFormat('h a').format(hourTime);
        } catch (_) {
          displayTime = h.time.split(' ').last;
        }

        final textColor = isTransparent ? Colors.white : Colors.black87;
        final subTextColor =
            isTransparent ? Colors.white70 : Colors.blueGrey.shade700;

        final BoxDecoration decoration = isNow
            ? BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.teal, Colors.cyan],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              )
            : BoxDecoration(
                color: isTransparent
                    ? Colors.white.withOpacity(0.2)
                    : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              );

        return Container(
          decoration: decoration,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.network(
                    h.iconUrl,
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isNow ? 'Now' : displayTime,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isNow ? Colors.white : textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        h.condition,
                        style: TextStyle(
                          fontSize: 13,
                          color: isNow ? Colors.white70 : subTextColor,
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
                    '${h.temp.toStringAsFixed(0)}°',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: isNow ? Colors.white : textColor,
                    ),
                  ),
                  Text(
                    '${h.chanceOfRain.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: isNow ? Colors.white70 : subTextColor,
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
