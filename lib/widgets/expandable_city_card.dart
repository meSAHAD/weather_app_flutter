import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import 'forecast_tab_card.dart';
import 'weather_icon.dart';

class ExpandableCityCard extends StatefulWidget {
  final Weather weather;
  final bool isEditing;
  final VoidCallback? onDelete;

  const ExpandableCityCard({
    super.key,
    required this.weather,
    this.isEditing = false,
    this.onDelete,
  });

  @override
  State<ExpandableCityCard> createState() => _ExpandableCityCardState();
}

class _ExpandableCityCardState extends State<ExpandableCityCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() => _expanded = !_expanded);
    _expanded ? _controller.forward() : _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.weather;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blueAccent, Colors.lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: InkWell(
        onTap: _toggleExpand,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  WeatherIcon(condition: w.condition, size: 42),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          w.cityName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          w.condition,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${w.temperature.toStringAsFixed(1)}°C',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Feels ${w.feelsLike.toStringAsFixed(1)}°',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                  if (widget.isEditing && widget.onDelete != null)
                    IconButton(
                      onPressed: widget.onDelete,
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                    ),
                ],
              ),
              SizeTransition(
                sizeFactor: _scale,
                axisAlignment: -1,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _infoItem('💨 Wind', '${w.windSpeed} km/h'),
                        _infoItem('☔ Rain', '${w.rainChance}%'),
                        _infoItem('🌡️ Min', '${w.minTemp}°'),
                        _infoItem('🔥 Max', '${w.maxTemp}°'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ForecastTabCard(weather: w),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}
