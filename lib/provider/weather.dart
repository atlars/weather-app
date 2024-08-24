import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weather_app/models/weather.dart';
import 'package:weather_app/repositories/weather.dart';

part 'weather.g.dart';

@riverpod
Future<Weather> weather(WeatherRef ref, WeatherRequest request) async {
  final weatherRepository = ref.watch(weatherRepositoryProvider);
  return weatherRepository.fetchWeatherForecast(request: request);
}