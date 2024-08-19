import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weather_app/models/weather.dart';
import 'package:weather_app/provider/http.dart';

part 'weather.g.dart';

@riverpod
Future<Weather> weather(WeatherRef ref, WeatherRequest request) async {
  final dio = ref.watch(dioProvider);

  final result = await dio.get(
    "https://api.open-meteo.com/v1/forecast",
    queryParameters: {
      "daily": "temperature_2m_min,temperature_2m_max,weather_code",
      "hourly": "temperature_2m,weather_code"
    }..addAll(request.toJson()),
  );

  print('Request URL: ${result.realUri}');

  return Weather.fromJson(result.data);
}