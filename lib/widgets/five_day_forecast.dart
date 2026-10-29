import 'package:flutter/material.dart';
import '../models/weather_data.dart';
import '../utils/weather_codes.dart';

class FiveDayForecast extends StatelessWidget {
  final List<DailyWeather> days;

  const FiveDayForecast({
    super.key,
    required this.days,
  });

  static const _weekdays = [
    'Երկ',
    'Երք',
    'Չրք',
    'Հնգ',
    'Ուրբ',
    'Շբթ',
    'Կիր',
  ];

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) return const SizedBox.shrink();

    final minAll =
        days.map((day) => day.minTemperature).reduce((a, b) => a < b ? a : b);

    final maxAll =
        days.map((day) => day.maxTemperature).reduce((a, b) => a > b ? a : b);

    final span = (maxAll - minAll).abs() < 1 ? 1.0 : maxAll - minAll;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(38),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '5 ՕՐՎԱ ԿԱՆԽԱՏԵՍՈՒՄ',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < days.length; i++)
            _dayRow(days[i], i, minAll, span),
        ],
      ),
    );
  }

  Widget _dayRow(
    DailyWeather day,
    int index,
    double minAll,
    double span,
  ) {
    final start = ((day.minTemperature - minAll) / span).clamp(0.0, 1.0);
    final end = ((day.maxTemperature - minAll) / span).clamp(0.0, 1.0);

    final name = index == 0 ? 'Այսօր' : _weekdays[(day.date.weekday - 1) % 7];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          SizedBox(
            width: 43,
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 23,
            child: Icon(
              weatherIcon(day.weatherCode),
              color: day.weatherCode <= 1
                  ? const Color(0xFFFFD15C)
                  : Colors.white70,
              size: 17,
            ),
          ),
          const SizedBox(width: 7),
          SizedBox(
            width: 28,
            child: Text(
              '${day.minTemperature.round()}°',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 5,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final left = constraints.maxWidth * start;
                  final width = (constraints.maxWidth * (end - start))
                      .clamp(8.0, constraints.maxWidth);

                  return Stack(
                    children: [
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      Positioned(
                        left: left,
                        width: width,
                        top: 0,
                        bottom: 0,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: day.weatherCode <= 1
                                ? const Color(0xFFFFD15C)
                                : const Color(0xFF9BC9DF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 32,
            child: Text(
              '${day.maxTemperature.round()}°',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
