import 'package:flutter/material.dart';
import '../models/weather_data.dart';
import '../utils/weather_codes.dart';

class HourlyForecast extends StatelessWidget {
  final List<HourlyWeather> hours;

  const HourlyForecast({
    super.key,
    required this.hours,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(42),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 9),
            child: Text(
              'ԺԱՄԱՅԻՆ',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                fontSize: 11,
              ),
            ),
          ),
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: hours.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final item = hours[index];
                final isNow = index == 0;

                return Container(
                  width: 52,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isNow
                        ? Colors.white.withValues(alpha: 0.16)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                    border: isNow ? Border.all(color: Colors.white24) : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isNow
                            ? 'Հիմա'
                            : '${item.time.hour.toString().padLeft(2, '0')}:00',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Icon(
                        weatherIcon(item.weatherCode),
                        color: item.weatherCode <= 1
                            ? const Color(0xFFFFD15C)
                            : Colors.white70,
                        size: 19,
                      ),
                      Text(
                        '${item.temperature.round()}°',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
