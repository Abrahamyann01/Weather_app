import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';

class WeatherService {
  static const _headers = {'Accept': 'application/json'};

  final http.Client _client;

  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  Future<WeatherData> fetchByCity(String city) async {
    final query = city.trim();

    if (query.isEmpty) {
      throw const WeatherException('Գրեք քաղաքի անունը։');
    }

    final geoUri = Uri.https(
      'geocoding-api.open-meteo.com',
      '/v1/search',
      {
        'name': query,
        'count': '1',
        'language': 'hy',
        'format': 'json',
      },
    );

    final geoResponse = await _client
        .get(geoUri, headers: _headers)
        .timeout(const Duration(seconds: 12));

    if (geoResponse.statusCode != 200) {
      throw const WeatherException(
        'Չհաջողվեց գտնել քաղաքը։ Փորձեք կրկին։',
      );
    }

    final geoJson = jsonDecode(geoResponse.body) as Map<String, dynamic>;
    final results = geoJson['results'] as List?;

    if (results == null || results.isEmpty) {
      throw const WeatherException(
        'Այս անունով քաղաք չգտնվեց։ Ստուգեք գրությունը։',
      );
    }

    final place = results.first as Map<String, dynamic>;
    final latitude = (place['latitude'] as num).toDouble();
    final longitude = (place['longitude'] as num).toDouble();
    final name = (place['name'] ?? query).toString();

    final weatherUri = Uri.https(
      'api.open-meteo.com',
      '/v1/forecast',
      {
        'latitude': '$latitude',
        'longitude': '$longitude',
        'current':
            'temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m',
        'hourly': 'temperature_2m,weather_code,precipitation_probability',
        'daily':
            'weather_code,temperature_2m_max,temperature_2m_min,sunset,uv_index_max',
        'forecast_days': '5',
        'timezone': 'auto',
        'wind_speed_unit': 'kmh',
      },
    );

    final response = await _client
        .get(weatherUri, headers: _headers)
        .timeout(const Duration(seconds: 12));

    if (response.statusCode != 200) {
      throw const WeatherException(
        'Եղանակի տվյալները հասանելի չեն։',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    return WeatherData.fromJson(
      city: name,
      latitude: latitude,
      longitude: longitude,
      json: json,
    );
  }

  void dispose() => _client.close();
}

class WeatherException implements Exception {
  final String message;

  const WeatherException(this.message);

  @override
  String toString() => message;
}
