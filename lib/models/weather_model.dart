class Weather {
  final String cityName;
  final double temperature;
  final double windSpeed;
  final double rainChance;
  final String condition;
  final List<ForecastDay> forecast;
  final List<HourlyForecast> hourly;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.windSpeed,
    required this.rainChance,
    required this.condition,
    required this.forecast,
    required this.hourly,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final forecastList = (json['forecast']?['forecastday'] as List?) ?? [];
    final hourlyList =
        forecastList.isNotEmpty ? (forecastList[0]['hour'] as List?) : [];

    return Weather(
      cityName: json['location']['name'] ?? 'Unknown',
      temperature: (json['current']['temp_c'] ?? 0).toDouble(),
      windSpeed: (json['current']['wind_kph'] ?? 0).toDouble(),
      rainChance: (json['current']['precip_mm'] ?? 0).toDouble(),
      condition: json['current']['condition']?['text'] ?? 'Unknown',
      forecast: forecastList.map((f) => ForecastDay.fromJson(f)).toList(),
      hourly: hourlyList != null
          ? hourlyList.map((h) => HourlyForecast.fromJson(h)).toList()
          : [],
    );
  }
}

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
