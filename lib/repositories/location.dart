import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weather_app/constants/urls.dart';
import 'package:weather_app/models/location.dart';
import 'package:weather_app/provider/http.dart';

part 'location.g.dart';

class LocationRepository {
  final Dio dio;

  const LocationRepository(this.dio);

  Future<List<City>> searchCity({String name = "", int count = 3, CancelToken? cancelToken}) async {
    final result = await dio.get(
      Urls.searchCities,
      queryParameters: {
        "name": name,
        "count": count,
        "format": "json",
        "language": "de",
      },
      cancelToken: cancelToken,
    );

    final resultList = ((result.data["results"] as List<dynamic>?) ?? []);

    return resultList.map((json) => City.fromJson(json as Map<String, Object?>)).toList();
  }
}

@riverpod
LocationRepository locationRepostiory(LocationRepostioryRef ref) {
  final dio = ref.watch(dioProvider);
  return LocationRepository(dio);
}
