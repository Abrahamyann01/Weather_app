import 'package:flutter/material.dart';
import '../models/weather_data.dart';
import '../controllers/weather_controller.dart';
import '../utils/app_colors.dart';
import '../utils/error_messages.dart';
import '../utils/weather_codes.dart';
import '../widgets/city_forecast_card.dart';
import '../widgets/info_tile.dart';

class CityWeatherScreen extends StatefulWidget {
  final String city;

  const CityWeatherScreen({super.key, required this.city});

  @override
  State<CityWeatherScreen> createState() => _CityWeatherScreenState();
}

class _CityWeatherScreenState extends State<CityWeatherScreen> {
  late final WeatherController _controller;
  late Future<WeatherData> _future;

  @override
  void initState() {
    super.initState();
    _controller = WeatherScope.read(context);
    _future = _controller.weather(widget.city);
  }

  void _reload() {
    setState(() {
      _future = _controller.weather(widget.city, force: true);
    });
  }

  Future<void> _refresh() async {
    try {
      final data = await _controller.weather(widget.city, force: true);
      if (!mounted) return;
      setState(() => _future = Future.value(data));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(errorMessage(e))));
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<WeatherData>(
          future: _future,
          initialData: _controller.cached(widget.city),
          builder: (context, snapshot) {
            if (snapshot.hasError) return _error(snapshot.error!);
            if (!snapshot.hasData) {
              return Column(
                children: [
                  _header(widget.city, null),
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ],
              );
            }
            return _body(snapshot.data!);
          },
        ),
      ),
    );
  }

  Widget _header(String city, DateTime? updated) {
    final time = updated == null
        ? null
        : '${updated.hour.toString().padLeft(2, '0')}:'
            '${updated.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.circle, size: 7, color: Colors.white),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        city,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                if (time != null)
                  Text(
                    '$time · open-meteo.com',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          if (updated != null) _updatedChip(),
        ],
      ),
    );
  }

  Widget _updatedChip() {
    return InkWell(
      onTap: _reload,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.successBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.successBorder, width: 2),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_rounded, size: 16, color: AppColors.successText),
            SizedBox(width: 6),
            Text(
              'Թարմացված',
              style: TextStyle(
                color: AppColors.successText,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(WeatherData data) {
    final day = data.daily.isNotEmpty ? data.daily.first : null;
    final sunny = data.weatherCode <= 1;

    final list = ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _header(data.city, data.fetchedAt),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 26),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(90),
                ),
                child: Row(
                  children: [
                    Icon(
                      weatherIcon(data.weatherCode),
                      size: 76,
                      color: sunny
                          ? AppColors.sun
                          : Colors.white.withValues(alpha: 0.92),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${data.temperature.round()}°',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 58,
                              height: 1,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            weatherDescription(data.weatherCode),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (day != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              '${day.maxTemperature.round()}° · '
                              '${day.minTemperature.round()}°',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InfoTile(
                      icon: Icons.air_rounded,
                      value: '${data.windSpeed.round()} կմ/ժ',
                      label: 'Քամի',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InfoTile(
                      icon: Icons.water_drop_outlined,
                      value: '${data.humidity}%',
                      label: 'Խոնավություն',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InfoTile(
                      icon: Icons.schedule_rounded,
                      value: _sunsetTime(data.sunset),
                      label: 'Մայրամուտ',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InfoTile(
                      icon: Icons.wb_twilight_rounded,
                      value: data.uvIndex == null
                          ? '—'
                          : data.uvIndex!.round().toString(),
                      label: 'UV ինդեքս',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              CityForecastCard(days: data.daily),
            ],
          ),
        ),
      ],
    );

    return RefreshIndicator(
      onRefresh: _refresh,
      child: list,
    );
  }

  String _sunsetTime(String? iso) {
    if (iso == null) return '—';
    final i = iso.indexOf('T');
    return i < 0 ? iso : iso.substring(i + 1);
  }

  Widget _error(Object error) {
    final message = errorMessage(error);

    return Column(
      children: [
        _header(widget.city, null),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isNetworkError(error)
                        ? Icons.wifi_off_rounded
                        : Icons.error_outline_rounded,
                    size: 60,
                    color: Colors.white70,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _reload,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Կրկնել'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.background,
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
}
