import 'package:flutter/material.dart';
import '../controllers/weather_controller.dart';
import '../models/weather_data.dart';
import '../services/weather_service.dart';
import '../utils/error_messages.dart';
import '../widgets/city_search_bar.dart';
import '../widgets/current_weather.dart';
import '../widgets/five_day_forecast.dart';
import '../widgets/hourly_forecast.dart';
import '../widgets/weather_background.dart';
import '../widgets/weather_details.dart';
import 'cities_screen.dart';

enum WeatherState {
  loading,
  loaded,
  error,
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _controller =
      TextEditingController(text: 'Երևան');

  late final WeatherController _store;

  WeatherState _state = WeatherState.loading;
  WeatherData? _data;

  Object _error = const WeatherException('Չհաջողվեց բեռնել տվյալները։');
  String _lastCity = 'Երևան';

  @override
  void initState() {
    super.initState();
    _store = WeatherScope.read(context);
    _load(_lastCity);
  }

  Future<void> _load(String city, {bool force = false}) async {
    setState(() {
      _state = WeatherState.loading;
    });

    try {
      final result = await _store.weather(city, force: force);

      if (!mounted) return;

      setState(() {
        _data = result;
        _lastCity = result.city;
        _controller.text = result.city;
        _state = WeatherState.loaded;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e;
        _state = WeatherState.error;
      });
    }
  }

  void _search() {
    final city = _controller.text.trim();
    if (city.isNotEmpty) {
      _load(city);
    }
  }

  void _openCities() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CitiesScreen()),
    );
  }

  void _retry() {
    final city = _controller.text.trim();
    _load(city.isEmpty ? _lastCity : city, force: true);
  }

  Future<void> _refresh() async {
    try {
      final result = await _store.weather(_lastCity, force: true);
      if (!mounted) return;
      setState(() {
        _data = result;
        _state = WeatherState.loaded;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(errorMessage(e))));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final code = _data?.weatherCode ?? 0;

    return Scaffold(
      body: WeatherBackground(
        weatherCode: code,
        child: SafeArea(
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_state) {
      case WeatherState.loading:
        return _loadingView();

      case WeatherState.error:
        return _errorView();

      case WeatherState.loaded:
        return _loadedBody(_data!);
    }
  }

  
  Widget _loadingView() {
    Widget skeleton({
      double? width,
      double height = 14,
      double radius = 12,
    }) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.20),
          borderRadius: BorderRadius.circular(radius),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: skeleton(height: 48, radius: 30),
              ),
              const SizedBox(width: 10),
              skeleton(width: 48, height: 48, radius: 30),
            ],
          ),
          const SizedBox(height: 38),
          skeleton(width: 78, height: 78, radius: 40),
          const SizedBox(height: 14),
          skeleton(width: 130, height: 60, radius: 16),
          const SizedBox(height: 12),
          skeleton(width: 110, height: 18),
          const SizedBox(height: 24),
          Row(
            children: [
              for (int i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: skeleton(height: 88, radius: 44),
                ),
              ],
            ],
          ),
          const SizedBox(height: 18),
          skeleton(height: 145, radius: 38),
          const SizedBox(height: 18),
          skeleton(height: 235, radius: 38),
          const SizedBox(height: 24),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 10),
              Text(
                'Բեռնվում է...',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  
  Widget _errorView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
          child: CitySearchBar(
            controller: _controller,
            onSearch: _search,
            onMyLocation: _openCities,
            busy: false,
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isNetworkError(_error)
                        ? Icons.wifi_off_rounded
                        : Icons.error_outline_rounded,
                    size: 64,
                    color: Colors.white70,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    errorTitle(_error),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    errorMessage(_error),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 22),
                  FilledButton.icon(
                    onPressed: _retry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Կրկնել'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF244F76),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _loadedBody(WeatherData data) {
    final scroll = CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              CitySearchBar(
                controller: _controller,
                onSearch: _search,
                onMyLocation: _openCities,
                busy: false,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 7, right: 6),
                  child: Text(
                    '✓ Թարմացված '
                    '${data.fetchedAt.hour.toString().padLeft(2, '0')}:'
                    '${data.fetchedAt.minute.toString().padLeft(2, '0')}'
                    ' · Open-Meteo',
                    style: const TextStyle(
                      color: Color(0xFF9BE8B8),
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
              CurrentWeather(data: data),
              const SizedBox(height: 25),
              WeatherDetails(data: data),
              const SizedBox(height: 18),
              HourlyForecast(hours: data.hourly),
              const SizedBox(height: 16),
              FiveDayForecast(days: data.daily),
              const SizedBox(height: 12),
              if (data.uvIndex != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'UV ինդեքս՝ ${data.uvIndex!.toStringAsFixed(1)}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ),
            ]),
          ),
        ),
      ],
    );

    return RefreshIndicator(
      onRefresh: _refresh,
      child: scroll,
    );
  }
}
