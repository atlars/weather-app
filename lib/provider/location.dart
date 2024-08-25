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

  final link = ref.keepAlive();
  ref.onDispose(() {
    link.close();
  });

  await Future<void>.delayed(const Duration(milliseconds: 250));

  if (cancelToken.isCancelled) {
    throw Exception('Cancelled');
  }

  return locationRepository.searchCity(name: search, count: 3, cancelToken: cancelToken);
}
