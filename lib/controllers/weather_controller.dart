import 'package:flutter/widgets.dart';
import '../models/weather_data.dart';
import '../services/city_storage.dart';
import '../services/weather_service.dart';

class WeatherController extends ChangeNotifier {
  WeatherController({WeatherService? service, CityStorage? storage})
      : _service = service ?? WeatherService(),
        _storage = storage ?? CityStorage();

  static const Duration _ttl = Duration(minutes: 10);

  final WeatherService _service;
  final CityStorage _storage;

  final Map<String, WeatherData> _cache = {};
  final Map<String, Future<WeatherData>> _pending = {};

  List<String> _cities = [];
  bool _citiesLoaded = false;

  List<String> get cities => List.unmodifiable(_cities);

  bool get citiesLoaded => _citiesLoaded;

  WeatherData? cached(String city) => _cache[city.trim()];

  bool _isFresh(WeatherData data) {
    return DateTime.now().difference(data.fetchedAt) < _ttl;
  }

  Future<WeatherData> weather(String city, {bool force = false}) {
    final key = city.trim();
    final hit = _cache[key];

    if (!force && hit != null && _isFresh(hit)) {
      return Future.value(hit);
    }

    final running = _pending[key];
    if (!force && running != null) return running;

    final request = _service.fetchByCity(key).then((data) {
      _cache[key] = data;
      _cache[data.city] = data;
      return data;
    }).whenComplete(() {
      _pending.remove(key);
    });

    _pending[key] = request;
    return request;
  }

  Future<void> loadCities() async {
    if (_citiesLoaded) return;
    _cities = await _storage.load();
    _citiesLoaded = true;
    notifyListeners();
  }

  Future<bool> addCity(String query) async {
    final data = await weather(query, force: true);
    if (_cities.contains(data.city)) return false;

    _cities.add(data.city);
    notifyListeners();
    await _storage.save(_cities);
    return true;
  }

  void removeCity(String city) {
    if (_cities.remove(city)) {
      notifyListeners();
      _storage.save(_cities);
    }
  }

  Future<void> resetCities() async {
    _cities = await _storage.reset();
    notifyListeners();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}

class WeatherScope extends InheritedNotifier<WeatherController> {
  const WeatherScope({
    super.key,
    required WeatherController controller,
    required super.child,
  }) : super(notifier: controller);

  static WeatherController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<WeatherScope>();
    assert(scope != null, 'WeatherScope-ը չի գտնվել վիջեթների ծառում');
    return scope!.notifier!;
  }

  static WeatherController read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<WeatherScope>();
    assert(scope != null, 'WeatherScope-ը չի գտնվել վիջեթների ծառում');
    return scope!.notifier!;
  }
}
