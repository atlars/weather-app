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

  ref.onDispose(() => print("Dipose $search"));

  await Future<void>.delayed(const Duration(milliseconds: 300));

  if (cancelToken.isCancelled) {
    throw Exception('Cancelled');
  }

  final result = locationRepository.searchCity(name: search, count: 5, cancelToken: cancelToken);
  ref.cacheFor(const Duration(minutes: 5));

  return result;
}
