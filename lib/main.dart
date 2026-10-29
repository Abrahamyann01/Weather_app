import 'package:flutter/material.dart';
import 'controllers/weather_controller.dart';
import 'screens/weather_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WeatherApp());
}

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  final WeatherController _controller = WeatherController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WeatherScope(
      controller: _controller,
      child: MaterialApp(
        title: 'Եղանակ',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF3D83B4),
          ),
        ),
        home: const WeatherScreen(),
      ),
    );
  }
}
