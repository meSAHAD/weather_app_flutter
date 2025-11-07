import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import 'hourly_forecast_section.dart';
import 'weekly_forecast_section.dart';

class ExpandableCityCard extends StatelessWidget {
  final Weather weather;

  const ExpandableCityCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF87CEFA), Color(0xFFE0F7FA)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            height: 5,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.white54,
              borderRadius: BorderRadius.circular(20),
            ),
          ),

          // City and temperature
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              children: [
                Text(
                  weather.cityName,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${weather.temperature.toStringAsFixed(1)}°C',
                  style: const TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  weather.condition,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Weather details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _infoTile(Icons.air, '${weather.windSpeed} km/h', 'Wind'),
              _infoTile(Icons.water_drop, '${weather.rainChance} mm', 'Rain'),
              _infoTile(Icons.cloud, weather.condition, 'Condition'),
            ],
          ),

          const SizedBox(height: 16),

          // Tabs for Hourly / Weekly
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const TabBar(
                      labelColor: Colors.black87,
                      unselectedLabelColor: Colors.black54,
                      indicatorColor: Colors.teal,
                      tabs: [
                        Tab(text: 'Hourly'),
                        Tab(text: '7 Days'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        HourlyForecastTab(hourly: weather.hourly),
                        WeeklyForecastTab(forecast: weather.forecast),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.black54, size: 26),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
              fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}
