import 'package:flutter/material.dart';
import '../models/weather_data.dart';
import '../utils/app_colors.dart';
import '../utils/weather_codes.dart';

class CityForecastCard extends StatelessWidget {
  final List<DailyWeather> days;

  const CityForecastCard({super.key, required this.days});

  static const _weekdays = ['Երկ', 'Երք', 'Չրք', 'Հինգ', 'Ուրբ', 'Շաբ', 'Կիր'];

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) return const SizedBox.shrink();

    final minAll =
        days.map((d) => d.minTemperature).reduce((a, b) => a < b ? a : b);
    final maxAll =
        days.map((d) => d.maxTemperature).reduce((a, b) => a > b ? a : b);
    final span = (maxAll - minAll) < 1 ? 1.0 : maxAll - minAll;

    return Container(
      padding: const EdgeInsets.fromLTRB(34, 30, 34, 26),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(90),
        border: Border.all(color: AppColors.cardBorder, width: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '5 ՕՐՎԱ ԿԱՆԽԱՏԵՍՈՒՄ',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          for (final day in days) _row(day, minAll, span),
        ],
      ),
    );
  }

  Widget _row(DailyWeather day, double minAll, double span) {
    final start = (day.minTemperature - minAll) / span;
    final end = (day.maxTemperature - minAll) / span;
    final rainy = isRainy(day.weatherCode);
    final sunny = day.weatherCode <= 1;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          SizedBox(
            width: 42,
            child: Text(
              _weekdays[day.date.weekday - 1],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          Icon(
            weatherIcon(day.weatherCode),
            size: 16,
            color: sunny ? AppColors.sun : AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final left = start * w;
                final width = ((end - start) * w).clamp(8.0, w);
                return SizedBox(
                  height: 6,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.track,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      Positioned(
                        left: left.clamp(0.0, w - width),
                        width: width,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: rainy ? AppColors.rainBar : AppColors.sun,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 64,
            child: Text(
              '${day.minTemperature.round()}°/${day.maxTemperature.round()}°',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
