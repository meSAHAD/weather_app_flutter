class Weather {
  final String cityName;
  final double temperature;
  final double windSpeed;
  final double rainChance;
  final String condition;
  final String iconUrl;
  final List<ForecastDay> forecast;
  final List<HourlyForecast> hourly;
  final double feelsLike;
  final double minTemp;
  final double maxTemp;
  final bool isDay;
  final double humidity;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.windSpeed,
    required this.rainChance,
    required this.condition,
    required this.iconUrl,
    required this.forecast,
    required this.hourly,
    required this.feelsLike,
    required this.minTemp,
    required this.maxTemp,
    required this.isDay,
    required this.humidity,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final forecastList = (json['forecast']?['forecastday'] as List?) ?? [];
    final hourlyList =
        forecastList.isNotEmpty ? (forecastList[0]['hour'] as List?) ?? [] : [];

    final todayDay = forecastList.isNotEmpty
        ? (forecastList[0]['day'] as Map<String, dynamic>?)
        : null;

    return Weather(
      cityName: json['location']?['name'] ?? 'Unknown',
      temperature: (json['current']?['temp_c'] ?? 0).toDouble(),
      windSpeed: (json['current']?['wind_kph'] ?? 0).toDouble(),
      rainChance: (json['current']?['precip_mm'] ?? 0).toDouble(),
      condition: json['current']?['condition']?['text'] ?? 'Unknown',
      iconUrl: json['current']?['condition']?['icon'] == null
          ? ''
          : "https:${json['current']['condition']['icon']}",
      forecast: forecastList.map((f) => ForecastDay.fromJson(f)).toList(),
      hourly: hourlyList.map((h) => HourlyForecast.fromJson(h)).toList(),
      feelsLike: (json['current']?['feelslike_c'] ?? 0).toDouble(),
      minTemp: (todayDay?['mintemp_c'] ?? 0).toDouble(),
      maxTemp: (todayDay?['maxtemp_c'] ?? 0).toDouble(),
      isDay: (json['current']?['is_day'] ?? 1) == 1,
      humidity: (json['current']?['humidity'] ?? 0).toDouble(),
    );
  }
}

/// ✅ Forecast for upcoming days
class ForecastDay {
  final String date;
  final double maxTemp;
  final double minTemp;
  final double rainChance;
  final String condition;
  final String iconUrl;

  ForecastDay({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.rainChance,
    required this.condition,
    required this.iconUrl,
  });

  factory ForecastDay.fromJson(Map<String, dynamic> json) {
    return ForecastDay(
      date: json['date'] ?? '',
      maxTemp: (json['day']?['maxtemp_c'] ?? 0).toDouble(),
      minTemp: (json['day']?['mintemp_c'] ?? 0).toDouble(),
      rainChance: (json['day']?['daily_chance_of_rain'] ?? 0).toDouble(),
      condition: json['day']?['condition']?['text'] ?? 'Unknown',
      iconUrl: "https:${json['day']?['condition']?['icon'] ?? ''}",
    );
  }
}

/// ✅ Hourly forecast for today
class HourlyForecast {
  final String time;
  final double temp;
  final double chanceOfRain;
  final String condition;
  final String iconUrl;

  HourlyForecast({
    required this.time,
    required this.temp,
    required this.chanceOfRain,
    required this.condition,
    required this.iconUrl,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      time: json['time'] ?? '',
      temp: (json['temp_c'] ?? 0).toDouble(),
      chanceOfRain: (json['chance_of_rain'] ?? 0).toDouble(),
      condition: json['condition']?['text'] ?? 'Unknown',
      iconUrl: "https:${json['condition']?['icon'] ?? ''}",
    );
  }
}
