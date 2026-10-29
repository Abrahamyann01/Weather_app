import 'package:shared_preferences/shared_preferences.dart';

class CityStorage {
  static const _key = 'saved_cities';

  static const defaultCities = ['Երևան', 'Գյումրի', 'Ջերմուկ'];

  Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return List<String>.of(prefs.getStringList(_key) ?? defaultCities);
  }

  Future<void> save(List<String> cities) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, cities);
  }

  Future<List<String>> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    return List<String>.of(defaultCities);
  }
}
