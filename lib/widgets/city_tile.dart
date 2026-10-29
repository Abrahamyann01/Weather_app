import 'package:flutter/material.dart';
import '../models/weather_data.dart';
import '../utils/app_colors.dart';
import '../utils/weather_codes.dart';

class CityTile extends StatelessWidget {
  final String city;
  final Future<WeatherData> future;
  final WeatherData? initial;
  final bool primary;
  final VoidCallback onTap;
  final VoidCallback onRetry;
  final VoidCallback onDelete;

  const CityTile({
    super.key,
    required this.city,
    required this.future,
    this.initial,
    required this.primary,
    required this.onTap,
    required this.onRetry,
    required this.onDelete,
  });

  static const _radius = 36.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radius),
        child: Dismissible(
          key: ValueKey(city),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => onDelete(),
          background: Container(
            color: AppColors.danger,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 28),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          child: Material(
            color: primary ? AppColors.accent : AppColors.card,
            child: InkWell(
              onTap: onTap,
              child: Container(
                constraints: const BoxConstraints(minHeight: 96),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_radius),
                  border: Border.all(
                    color: primary
                        ? AppColors.accentBorder
                        : AppColors.cardBorder,
                    width: 3,
                  ),
                ),
                child: FutureBuilder<WeatherData>(
                  future: future,
                  initialData: initial,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) return _error();
                    if (!snapshot.hasData) return _loading();
                    return _content(snapshot.data!);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _title() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (primary) ...[
          const Icon(Icons.circle, size: 7, color: Colors.white),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            city,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _content(WeatherData data) {
    final sunny = data.weatherCode <= 1;
    final day = data.daily.isNotEmpty ? data.daily.first : null;

    const small = TextStyle(color: Colors.white70, fontSize: 12, height: 1.35);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _title(),
              const SizedBox(height: 3),
              Text(
                weatherDescription(data.weatherCode),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: small.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                'Զգացվում է ${data.apparentTemperature.round()}°',
                style: small,
              ),
              if (day != null)
                Text(
                  '${day.maxTemperature.round()}° / ${day.minTemperature.round()}°',
                  style: small,
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Icon(
          weatherIcon(data.weatherCode),
          size: 26,
          color: sunny ? AppColors.sun : Colors.white.withValues(alpha: 0.9),
        ),
        const SizedBox(width: 10),
        Text(
          '${data.temperature.round()}°',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }

  Widget _loading() {
    return Row(
      children: [
        Expanded(child: _title()),
        const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        ),
      ],
    );
  }

  Widget _error() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _title(),
              const SizedBox(height: 3),
              const Text(
                'Տվյալները հասանելի չեն',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onRetry,
          tooltip: 'Կրկնել',
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
        ),
      ],
    );
  }
}
