import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weather_app/models/location.dart';
import 'package:weather_app/repositories/location.dart';
import 'package:weather_app/util/extensions.dart';

part 'location.g.dart';

@riverpod
Future<List<City>> searchCity(SearchCityRef ref, {String search = ""}) async {
  final cancelToken = ref.cancelToken();
  final locationRepository = ref.watch(locationRepostioryProvider);

  if (search.isEmpty) return [];

  await Future<void>.delayed(const Duration(milliseconds: 300));

  if (cancelToken.isCancelled) {
    throw Exception('Cancelled');
  }

  return locationRepository.searchCity(name: search, count: 3, cancelToken: cancelToken);
}
