import 'package:flutter/material.dart';
import '../models/weather_data.dart';
import '../utils/weather_codes.dart';

class CurrentWeather extends StatelessWidget {
  final WeatherData data;

  const CurrentWeather({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final sunny = data.weatherCode <= 1;

    return Column(
      children: [
        const SizedBox(height: 28),
        Icon(
          weatherIcon(data.weatherCode),
          size: 78,
          color: sunny
              ? const Color(0xFFFFD15C)
              : Colors.white.withValues(alpha: 0.92),
        ),
        const SizedBox(height: 8),
        Text(
          '${data.temperature.round()}°',
          style: const TextStyle(
            fontSize: 62,
            height: 1,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          weatherDescription(data.weatherCode),
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          children: [
            Text(
              'Զգացվում է ${data.apparentTemperature.round()}°',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            if (data.daily.isNotEmpty)
              Text(
                'Օր ${data.daily.first.maxTemperature.round()}°',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            if (data.daily.isNotEmpty)
              Text(
                'Գիշեր ${data.daily.first.minTemperature.round()}°',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
