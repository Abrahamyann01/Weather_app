import 'package:flutter/material.dart';
import '../utils/weather_codes.dart';

class WeatherBackground extends StatelessWidget {
  final int weatherCode;
  final Widget child;

  const WeatherBackground({
    super.key,
    required this.weatherCode,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final rainy = isRainy(weatherCode);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: rainy
              ? const [
                  Color(0xFF243F59),
                  Color(0xFF416C8C),
                  Color(0xFF638BA5),
                ]
              : const [
                  Color(0xFF204F7F),
                  Color(0xFF2F6F9F),
                  Color(0xFF4A8AB4),
                ],
        ),
      ),
      child: child,
    );
  }
}
