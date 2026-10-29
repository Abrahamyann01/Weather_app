import 'dart:async';
import 'package:http/http.dart' as http;
import '../services/weather_service.dart';

bool isNetworkError(Object error) {
  return error is TimeoutException || error is http.ClientException;
}

String errorTitle(Object error) {
  if (isNetworkError(error)) return 'Կապը հասանելի չէ';
  if (error is WeatherException) return 'Չհաջողվեց բեռնել';
  return 'Սխալ առաջացավ';
}

String errorMessage(Object error) {
  if (error is WeatherException) return error.message;
  if (isNetworkError(error)) return 'Ստուգեք ինտերնետ կապը և կրկին փորձեք։';
  return 'Տվյալները մշակել չհաջողվեց։ Փորձեք կրկին։';
}
