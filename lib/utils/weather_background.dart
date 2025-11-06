import 'package:flutter/material.dart';

class WeatherBackground {
  static LinearGradient getGradient(String condition) {
    condition = condition.toLowerCase();

    if (condition.contains('sun') || condition.contains('clear')) {
      // ☀️ Sunny
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
      );
    } else if (condition.contains('cloud')) {
      // ☁️ Cloudy
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF90A4AE), Color(0xFF546E7A)],
      );
    } else if (condition.contains('rain') || condition.contains('drizzle')) {
      // 🌧️ Rainy
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF4FC3F7), Color(0xFF0288D1)],
      );
    } else if (condition.contains('snow')) {
      // ❄️ Snowy
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFE0F7FA), Color(0xFFB3E5FC)],
      );
    } else {
      // Default 🌆
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFB0BEC5), Color(0xFF78909C)],
      );
    }
  }
}
