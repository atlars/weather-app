import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weather_app/models/location.dart';
import 'package:weather_app/repositories/location.dart';
import 'package:weather_app/util/extensions.dart';

part 'location.g.dart';

@riverpod
Future<List<City>> searchCity(SearchCityRef ref, {String search = ""}) async {
  if (search.isEmpty) return [];

  final cancelToken = ref.cancelToken();
  final locationRepository = ref.watch(locationRepostioryProvider);

  ref.cacheFor(const Duration(minutes: 5));
  
  ref.onDispose(() => print("Dispose $search"));

  return locationRepository.searchCity(name: search, count: 5, cancelToken: cancelToken);
}
