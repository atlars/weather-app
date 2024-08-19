import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weather_app/constants/urls.dart';
import 'package:weather_app/models/weather.dart';
import 'package:weather_app/provider/http.dart';
import 'package:weather_app/util/extensions.dart';

part 'location.g.dart';

@riverpod
Future<List<City>> searchCity(SearchCityRef ref, {String search = ""}) async {
  final cancelToken = ref.cancelToken();
  final dio = ref.watch(dioProvider);

  if (search.isEmpty) return [];

  await Future<void>.delayed(const Duration(milliseconds: 300));

  if (cancelToken.isCancelled) {
    throw Exception('Cancelled');
  }

  final result = await dio.get(
    Urls.searchCities,
    queryParameters: {
      "name": search,
      "count": 3,
      "format": "json",
      "language": "de",
    },
    cancelToken: cancelToken,
  );

  final resultList = ((result.data["results"] as List<dynamic>?) ?? []);

  return resultList
      .map((json) => City.fromJson(json as Map<String, Object?>))
      .toList();
}