import 'package:flutter/material.dart';

class WeatherIcon extends StatelessWidget {
  final String condition;
  final double size;

  const WeatherIcon({super.key, required this.condition, this.size = 48});

  @override
  Widget build(BuildContext context) {
    String emoji;
    final c = condition.toLowerCase();
    if (c.contains('rain'))
      emoji = '🌧️';
    else if (c.contains('cloud'))
      emoji = '☁️';
    else if (c.contains('sun') || c.contains('clear'))
      emoji = '☀️';
    else if (c.contains('snow'))
      emoji = '❄️';
    else
      emoji = '🌤️';

    return Text(emoji, style: TextStyle(fontSize: size));
  }
}
