import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weather_app/constants/urls.dart';
import 'package:weather_app/models/weather.dart';
import 'package:weather_app/provider/http.dart';

part 'weather.g.dart';

class WeatherRepository {
  final Dio dio;

  const WeatherRepository(this.dio);

  Future<Weather> fetchWeatherForecast({required WeatherRequest request, CancelToken? cancelToken}) async {
    final result = await dio.get(
      Urls.weatherForecast,
      queryParameters: {
        "daily": "temperature_2m_min,temperature_2m_max,weather_code",
        "hourly": "temperature_2m,weather_code"
      }..addAll(request.toJson()),
    );

    return Weather.fromJson(result.data);
  }
}

@riverpod
WeatherRepository weatherRepository(WeatherRepositoryRef ref) {
  final dio = ref.watch(dioProvider);
  return WeatherRepository(dio);
}
