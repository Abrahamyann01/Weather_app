import 'package:flutter/material.dart';
import '../controllers/weather_controller.dart';
import '../models/weather_data.dart';
import '../utils/app_colors.dart';
import '../utils/error_messages.dart';
import '../widgets/city_tile.dart';
import 'city_weather_screen.dart';

class CitiesScreen extends StatefulWidget {
  const CitiesScreen({super.key});

  @override
  State<CitiesScreen> createState() => _CitiesScreenState();
}

class _CitiesScreenState extends State<CitiesScreen> {
  final TextEditingController _input = TextEditingController();
  final Map<String, Future<WeatherData>> _futures = {};
  late final WeatherController _store;
  bool _adding = false;

  @override
  void initState() {
    super.initState();
    _store = WeatherScope.read(context);
    _store.loadCities();
  }

  void _sync(List<String> cities) {
    for (final city in cities) {
      _futures.putIfAbsent(city, () => _store.weather(city));
    }
    _futures.removeWhere((city, _) => !cities.contains(city));
  }

  Future<void> _addCity() async {
    final query = _input.text.trim();
    if (query.isEmpty || _adding) return;

    FocusScope.of(context).unfocus();
    setState(() => _adding = true);

    try {
      final added = await _store.addCity(query);
      if (!mounted) return;

      if (added) {
        _input.clear();
      } else {
        _snack('Այս քաղաքն արդեն ցուցակում է։');
      }
    } catch (e) {
      if (!mounted) return;
      _snack(errorMessage(e));
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  void _retry(String city) {
    setState(() => _futures[city] = _store.weather(city, force: true));
  }

  Future<void> _onMenu(String value) async {
    if (value == 'refresh') {
      setState(() {
        for (final city in _store.cities) {
          _futures[city] = _store.weather(city, force: true);
        }
      });
    } else if (value == 'reset') {
      await _store.resetCities();
    }
  }

  void _openCity(String city) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CityWeatherScreen(city: city)),
    );
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = WeatherScope.of(context);
    final cities = store.cities;
    _sync(cities);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 18),
              _addField(),
              const SizedBox(height: 18),
              Expanded(child: _list(store, cities)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
        const Expanded(
          child: Text(
            'Քաղաքներ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            color: AppColors.cardBorder,
            shape: BoxShape.circle,
          ),
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.menu_rounded, color: Colors.white),
            color: AppColors.card,
            onSelected: _onMenu,
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'refresh',
                child: Text(
                  'Թարմացնել',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              PopupMenuItem(
                value: 'reset',
                child: Text(
                  'Վերականգնել ցուցակը',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _addField() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.cardBorder, width: 3),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _input,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _addCity(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                hintText: 'Ավելացնել քաղաք...',
                hintStyle: TextStyle(color: AppColors.textSecondary),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (_adding)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          else
            IconButton(
              onPressed: _addCity,
              tooltip: 'Ավելացնել',
              icon: const Icon(Icons.add_rounded, color: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _list(WeatherController store, List<String> cities) {
    if (!store.citiesLoaded) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (cities.isEmpty) {
      return const Center(
        child: Text(
          'Ցուցակը դատարկ է։ Ավելացրեք քաղաք։',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: cities.length,
      itemBuilder: (context, index) {
        final city = cities[index];
        return CityTile(
          key: ValueKey(city),
          city: city,
          future: _futures[city]!,
          initial: store.cached(city),
          primary: index == 0,
          onTap: () => _openCity(city),
          onRetry: () => _retry(city),
          onDelete: () => store.removeCity(city),
        );
      },
    );
  }
}
