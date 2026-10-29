class WeatherData {
  final String city;
  final double latitude;
  final double longitude;
  final DateTime fetchedAt;
  final double temperature;
  final double apparentTemperature;
  final double windSpeed;
  final int humidity;
  final String? sunset;
  final double? uvIndex;
  final int weatherCode;
  final List<HourlyWeather> hourly;
  final List<DailyWeather> daily;

  const WeatherData({
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.fetchedAt,
    required this.temperature,
    required this.apparentTemperature,
    required this.windSpeed,
    required this.humidity,
    required this.sunset,
    required this.uvIndex,
    required this.weatherCode,
    required this.hourly,
    required this.daily,
  });

  factory WeatherData.fromJson({
    required String city,
    required double latitude,
    required double longitude,
    required Map<String, dynamic> json,
  }) {
    final current = json['current'] as Map<String, dynamic>? ?? {};
    final hourlyJson = json['hourly'] as Map<String, dynamic>? ?? {};
    final dailyJson = json['daily'] as Map<String, dynamic>? ?? {};

    final times = (hourlyJson['time'] as List? ?? []).cast<String>();
    final temps = hourlyJson['temperature_2m'] as List? ?? [];
    final codes = hourlyJson['weather_code'] as List? ?? [];
    final precip = hourlyJson['precipitation_probability'] as List? ?? [];

    final now = DateTime.now();
    int start = times.indexWhere(
      (t) => !DateTime.parse(t).isBefore(now),
    );
    if (start < 0) start = 0;

    final hourly = <HourlyWeather>[];
    for (var i = start; i < times.length && hourly.length < 12; i++) {
      hourly.add(
        HourlyWeather(
          time: DateTime.parse(times[i]),
          temperature: _numAt(temps, i),
          weatherCode: _intAt(codes, i),
          precipitationProbability: _intAt(precip, i),
        ),
      );
    }

    final dayTimes = (dailyJson['time'] as List? ?? []).cast<String>();
    final maxes = dailyJson['temperature_2m_max'] as List? ?? [];
    final mins = dailyJson['temperature_2m_min'] as List? ?? [];
    final dayCodes = dailyJson['weather_code'] as List? ?? [];

    final daily = <DailyWeather>[];
    for (var i = 0; i < dayTimes.length && i < 5; i++) {
      daily.add(
        DailyWeather(
          date: DateTime.parse(dayTimes[i]),
          maxTemperature: _numAt(maxes, i),
          minTemperature: _numAt(mins, i),
          weatherCode: _intAt(dayCodes, i),
        ),
      );
    }

    final sunsets = dailyJson['sunset'] as List? ?? [];
    final uvValues = dailyJson['uv_index_max'] as List? ?? [];

    return WeatherData(
      city: city,
      latitude: latitude,
      longitude: longitude,
      fetchedAt: DateTime.now(),
      temperature: _num(current['temperature_2m']),
      apparentTemperature: _num(current['apparent_temperature']),
      windSpeed: _num(current['wind_speed_10m']),
      humidity: _num(current['relative_humidity_2m']).round(),
      sunset: sunsets.isNotEmpty ? sunsets.first.toString() : null,
      uvIndex: uvValues.isNotEmpty ? _num(uvValues.first) : null,
      weatherCode: _int(current['weather_code']),
      hourly: hourly,
      daily: daily,
    );
  }

  static double _num(dynamic value) => value is num ? value.toDouble() : 0;

  static int _int(dynamic value) => value is num ? value.toInt() : 0;

  static double _numAt(List values, int index) =>
      index < values.length && values[index] is num
          ? (values[index] as num).toDouble()
          : 0;

  static int _intAt(List values, int index) =>
      index < values.length && values[index] is num
          ? (values[index] as num).toInt()
          : 0;
}

class HourlyWeather {
  final DateTime time;
  final double temperature;
  final int weatherCode;
  final int precipitationProbability;

  const HourlyWeather({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.precipitationProbability,
  });
}

class DailyWeather {
  final DateTime date;
  final double maxTemperature;
  final double minTemperature;
  final int weatherCode;

  const DailyWeather({
    required this.date,
    required this.maxTemperature,
    required this.minTemperature,
    required this.weatherCode,
  });
}
