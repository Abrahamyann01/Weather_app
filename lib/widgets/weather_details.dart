import 'package:flutter/material.dart';
import '../models/weather_data.dart';

class WeatherDetails extends StatelessWidget {
  final WeatherData data;

  const WeatherDetails({
    super.key,
    required this.data,
  });

  String _sunset() {
    if (data.sunset == null) return '—';

    final dt = DateTime.tryParse(data.sunset!);
    if (dt == null) return '—';

    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.air_rounded, '${data.windSpeed.round()} կմ/ժ', 'Քամի'),
      (
        Icons.water_drop_outlined,
        '${data.humidity}%',
        'Խոնավություն',
      ),
      (Icons.wb_twilight_rounded, _sunset(), 'Մայրամուտ'),
    ];

    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 9),
          Expanded(
            child: Container(
              height: 88,
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(44),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    items[i].$1,
                    color: Colors.white70,
                    size: 19,
                  ),
                  const SizedBox(height: 5),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      items[i].$2,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    items[i].$3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
