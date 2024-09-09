import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weather_app/constants/prefs.dart';
import 'package:weather_app/models/location.dart';
import 'package:weather_app/provider/prefs.dart';
import 'package:weather_app/repositories/location.dart';
import 'package:weather_app/util/extensions.dart';

part 'location.g.dart';

@riverpod
Future<List<City>> searchCity(SearchCityRef ref, {String search = ""}) async {
  if (search.isEmpty) return [];

  final cancelToken = ref.cancelToken();
  final locationRepository = ref.watch(locationRepostioryProvider);

  await Future<void>.delayed(const Duration(milliseconds: 300));

  if (cancelToken.isCancelled) {
    throw Exception('Cancelled');
  }

  final result = locationRepository.searchCity(name: search, count: 5, cancelToken: cancelToken);
  ref.cacheFor(const Duration(minutes: 5));

  return result;
}

@riverpod
class FavoriteCities extends _$FavoriteCities {
  @override
  List<City> build() {
    final prefs = ref.watch(prefsProvider).requireValue;
    final rawCities = prefs.getStringList(PrefsKeys.favoriteCities) ?? [];
    final cities = rawCities.map((cityString) => City.fromJson(jsonDecode(cityString))).toList();

    return cities;
  }

  Future<void> saveData() {
    final prefs = ref.read(prefsProvider).requireValue;
    return prefs.setStringList(PrefsKeys.favoriteCities, state.map((city) => jsonEncode(city.toJson())).toList());
  }

  void remove(City city) {
    state.removeWhere((item) => item.id == city.id);
    state = [...state];
    saveData();
  }

  void add(City city) {
    if(state.any((e) => e.id == city.id)) return;
    state = [city, ...state];
    saveData();
  }
}

@riverpod
class SelectedCity extends _$SelectedCity {
  @override
  City? build() {
    final prefs = ref.watch(prefsProvider).requireValue;
    final rawCity = prefs.getString(PrefsKeys.selectedCity) ?? "";
    if (rawCity.isEmpty) return null;

    return City.fromJson(jsonDecode(rawCity));
  }

  void set(City? city) async {
    final prefs = ref.read(prefsProvider).requireValue;
    if (city == null) {
      await prefs.remove(PrefsKeys.selectedCity);
    } else {
      await prefs.setString(PrefsKeys.selectedCity, jsonEncode(city.toJson()));
    }
    ref.invalidateSelf();
  }
}
