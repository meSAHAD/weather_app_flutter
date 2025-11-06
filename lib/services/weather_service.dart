import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../utils/constants.dart';

class WeatherService {
  final String baseUrl = 'https://api.weatherapi.com/v1/forecast.json';

  Future<Weather> fetchWeather(String cityName) async {
    final url =
        Uri.parse('$baseUrl?key=$apiKey&q=$cityName&days=7&aqi=no&alerts=no');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Weather.fromJson(data);
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
