import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/models/location.dart';
import 'package:weather_app/models/weather.dart';
import 'package:weather_app/provider/location.dart';
import 'package:weather_app/provider/weather.dart';
import 'package:weather_app/ui/widgets/weather_item.dart';
import 'package:weather_app/util/location.dart';

class WeatherPage extends ConsumerStatefulWidget {
  const WeatherPage({super.key});

  @override
  ConsumerState<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends ConsumerState<WeatherPage> {
  final SearchController _searchController = SearchController();
  City? _selectedCity;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: _buildNewSearchBar(), shape: Border(bottom: BorderSide(width: 1, color: Colors.grey.shade300))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            if (_selectedCity != null)
              Padding(
                padding: const EdgeInsets.only(top: 62, left: 10, right: 10),
                child: _buildWeather(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewSearchBar() {
    return GestureDetector(
      onTap: () async {
        final result = await showSearch(context: context, delegate: SearchCityDelegate());
        if (result != null) {
          setState(() => _selectedCity = result);
        }
        ref.invalidate(searchCityProvider);
      },
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.transparent),
            color: Colors.grey.shade200),
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.search,
              size: 22,
            ),
            const SizedBox(
              width: 8,
            ),
            Text(
              _selectedCity?.name ?? "Search",
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeather() {
    final city = _selectedCity!;
    final weatherResult = ref.watch(
      weatherProvider(
        WeatherRequest(longitude: city.longitude, latitude: city.latitude, forecastHours: 24),
      ),
    );
    return weatherResult.when(
      data: (weather) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentWeather(weather, city),
            _buildHourlyWeather(weather),
          ],
        );
      },
      error: (error, stacktrace) => const Text("Error"),
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 22),
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildCurrentWeather(Weather weather, City city) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          city.name,
          style: theme.textTheme.headlineLarge,
        ),
        Text(
          '${weather.daily.minTemperatues.first}°/${weather.daily.maxTemperatues.first}°',
          style: theme.textTheme.headlineMedium,
        )
      ],
    );
  }

  Widget _buildHourlyWeather(Weather weather) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: weather.hourly.time.mapIndexed((index, time) {
          return Column(
            children: [
              Text(DateFormat('HH:mm').format(weather.hourly.time[index])),
              const SizedBox(
                height: 12,
              ),
              WeatherItem(
                wmoCode: weather.hourly.weatherCodes[index],
                temperature: weather.hourly.temperatues[index],
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class SearchCityDelegate extends SearchDelegate<City?> {
  SearchCityDelegate()
      : super(
          searchFieldLabel: "Search a city",
          searchFieldStyle: TextStyle(fontSize: 16, color: Colors.grey.shade800),
        );

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () => query = "",
        icon: const Icon(Icons.close),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _SearchSuggestions(
      query: query,
      onSuggestionClicked: (city) {
        close(context, city);
      },
    );
  }
}

class _SearchSuggestions extends ConsumerWidget {
  final String query;
  final Function(City) onSuggestionClicked;

  const _SearchSuggestions({required this.query, required this.onSuggestionClicked});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cities = ref.watch(searchCityProvider(search: query.trim()));
    return cities.when(
      data: (data) {
        return _buildSuggestions(data);
      },
      error: (error, _) {
        return const Center(
          child: Text("Cannot fetch suggestions"),
        );
      },
      loading: () {
        if (cities.valueOrNull != null) {
          return _buildSuggestions(cities.value!);
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildSuggestions(List<City> cities) {
    return ListView(children: cities.map((city) => _buildCitySuggestion(city)).toList());
  }

  Widget _buildCitySuggestion(City city) {
    return ListTile(
      leading: Text(
        LocationUtils.countryCodeToEmoji(city.countryCode),
        style: const TextStyle(
          fontFamily: "NotoColorEmoji",
          fontSize: 16,
        ),
      ),
      title: Text(city.name),
      subtitle: Text('${city.admin1 ?? ''}, ${city.country}'),
      onTap: () => onSuggestionClicked(city),
    );
  }
}
